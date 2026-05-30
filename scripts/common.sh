#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TFVARS_FILE="${TFVARS_FILE:-${MODULE_DIR}/value.tfvars}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

read_tfvar() {
  local key="$1"
  local file="$2"
  local line value

  line="$(grep -E "^[[:space:]]*${key}[[:space:]]*=" "$file" | head -n 1 || true)"
  if [[ -z "$line" ]]; then
    echo "error: ${key} not found in ${file}" >&2
    return 1
  fi

  value="$(sed -E 's/^[^=]*=[[:space:]]*"?([^"]+)"?.*/\1/' <<<"$line")"
  echo "$value"
}

read_tfvar_optional() {
  local key="$1"
  local default="$2"
  local file="$3"

  if grep -qE "^[[:space:]]*${key}[[:space:]]*=" "$file"; then
    read_tfvar "$key" "$file"
  else
    echo "$default"
  fi
}

get_vm_names() {
  local file="$1"
  local in_block=0
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^vm_instances[[:space:]]*= ]]; then
      in_block=1
      continue
    fi

    if (( in_block )) && [[ "$line" =~ ^[a-z_]+[[:space:]]*= ]]; then
      break
    fi

    if (( in_block )) && [[ "$line" =~ name[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
      echo "${BASH_REMATCH[1]}"
    fi
  done < "$file"
}

load_config() {
  if [[ ! -f "$TFVARS_FILE" ]]; then
    echo "error: tfvars file not found: ${TFVARS_FILE}" >&2
    exit 1
  fi

  PROJECT_ID="${PROJECT_ID:-$(read_tfvar project_id "$TFVARS_FILE")}"
  REGION="${REGION:-$(read_tfvar_optional region asia-southeast1 "$TFVARS_FILE")}"
  ZONE="${ZONE:-$(read_tfvar_optional zone a "$TFVARS_FILE")}"
  GCP_ZONE="${GCP_ZONE:-${REGION}-${ZONE}}"

  if [[ -n "${VM_NAMES:-}" ]]; then
    # shellcheck disable=SC2206
    VM_LIST=(${VM_NAMES})
  else
    VM_LIST=()
    while IFS= read -r vm_name; do
      VM_LIST+=("$vm_name")
    done < <(get_vm_names "$TFVARS_FILE")
  fi

  if ((${#VM_LIST[@]} == 0)); then
    echo "error: no VM names found in ${TFVARS_FILE}" >&2
    exit 1
  fi
}

run_vm_instance_action() {
  local action="$1"
  local instance="$2"

  echo "==> ${action} ${instance}"
  gcloud compute instances "${action}" "$instance" \
    --project="$PROJECT_ID" \
    --zone="$GCP_ZONE" \
    --quiet
}

run_vm_action() {
  local action="$1"
  local instance pid failed=0
  local -a pids=()

  require_command gcloud
  load_config

  echo "project: ${PROJECT_ID}"
  echo "zone:    ${GCP_ZONE}"
  echo "action:  ${action}"
  echo "vms:     ${VM_LIST[*]}"
  echo

  for instance in "${VM_LIST[@]}"; do
    run_vm_instance_action "$action" "$instance" &
    pids+=("$!")
  done

  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      failed=$((failed + 1))
    fi
  done

  echo
  if (( failed > 0 )); then
    echo "error: ${action} failed for ${failed} of ${#VM_LIST[@]} instance(s)" >&2
    exit 1
  fi

  echo "done: ${action} completed for ${#VM_LIST[@]} instance(s)"
}
