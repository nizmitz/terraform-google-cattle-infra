# terraform-google-cattle-infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.12.0, < 8 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.12.0, < 8 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 7.33.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 7.33.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.3.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_dns-private-zone"></a> [dns-private-zone](#module\_dns-private-zone) | terraform-google-modules/cloud-dns/google | ~> 7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google-beta_google_compute_global_address.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_address) | resource |
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.this_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_kms_crypto_key.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_key_ring.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_sql_database_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_compute_configuration"></a> [compute\_configuration](#input\_compute\_configuration) | common configuration for all compute instances | <pre>object({<br/>    os_project = string<br/>    os_family  = string<br/>    ssh_user   = string<br/>  })</pre> | <pre>{<br/>  "os_family": "debian-12",<br/>  "os_project": "debian-cloud",<br/>  "ssh_user": "terraform"<br/>}</pre> | no |
| <a name="input_dns_private_zone"></a> [dns\_private\_zone](#input\_dns\_private\_zone) | Specification that will be used for dns\_private\_zone | <pre>list(object({<br/>    name   = string<br/>    domain = string<br/>    recordsets = list(object({<br/>      name    = string<br/>      type    = string<br/>      ttl     = number<br/>      records = list(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Specification that will be used for firewall rules | <pre>list(object({<br/>    name          = string<br/>    description   = optional(string)<br/>    source_ranges = list(string)<br/>    target_tags   = list(string)<br/>    allow         = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_nat_configuration"></a> [nat\_configuration](#input\_nat\_configuration) | Specification that will be used for nat\_configuration | <pre>object({<br/>    network_tier                   = optional(string, "PREMIUM")<br/>    enable_dynamic_port_allocation = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | common configuration for the VPC | <pre>object({<br/>    ip_cidr_range = list(string)<br/>  })</pre> | <pre>{<br/>  "ip_cidr_range": [<br/>    "172.10.0.0/16"<br/>  ]<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id of the project that holds the network. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the project that is hosted. | `string` | `"asia-southeast1"` | no |
| <a name="input_sql_instances"></a> [sql\_instances](#input\_sql\_instances) | Specification that will be used for sql\_instances | <pre>list(object({<br/>    name                        = string<br/>    tier                        = string<br/>    database_version            = string<br/>    edition                     = string<br/>    availability_type           = string<br/>    disk_size                   = number<br/>    disk_type                   = string<br/>    deletion_protection_enabled = bool<br/>    private_network             = bool<br/>    query_insights_enabled      = bool<br/>    ssl_mode                    = string<br/>    database_flags = list(object({<br/>      name  = string<br/>      value = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_vm_instances"></a> [vm\_instances](#input\_vm\_instances) | Specification that will be used for vm instances | <pre>list(object({<br/>    name                        = string<br/>    machine_type                = string<br/>    description                 = optional(string)<br/>    network_tags                = optional(list(string))<br/>    disk_size                   = optional(number)<br/>    nat_ip                      = optional(bool, false)<br/>    enable_secure_boot          = optional(bool, false)<br/>    enable_vtpm                 = optional(bool, false)<br/>    enable_integrity_monitoring = optional(bool, false)<br/>    enable_disk_encryption      = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone of the project that is hosted. | `string` | `"a"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nat_properties"></a> [nat\_properties](#output\_nat\_properties) | n/a |
| <a name="output_sql_properties"></a> [sql\_properties](#output\_sql\_properties) | n/a |
| <a name="output_vm_properties"></a> [vm\_properties](#output\_vm\_properties) | n/a |
<!-- END_TF_DOCS -->
