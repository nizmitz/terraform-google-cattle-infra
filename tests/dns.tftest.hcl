variables {
  project_id = "mock-project"
  region     = "asia-southeast1"
  zone       = "a"
  test_vm = {
    name                   = "node-1"
    machine_type           = "e2-medium"
    enable_disk_encryption = true
  }
}

run "dns_creates_private_zone" {
  command = plan

  variables {
    dns_private_zone = [{
      name   = "test-zone"
      domain = "example.internal."
      recordsets = [{
        name    = "localhost"
        type    = "A"
        ttl     = 300
        records = ["127.0.0.1"]
      }]
    }]
    vm_instances   = []
    firewall_rules = []
    sql_instances  = []
  }

  assert {
    condition     = length(module.dns-private-zone) == 1
    error_message = "One DNS module instance must be created per dns_private_zone entry."
  }

  assert {
    condition     = contains(keys(module.dns-private-zone), "test-zone")
    error_message = "DNS module must be keyed by zone name."
  }

  assert {
    condition     = module.dns-private-zone["test-zone"].domain == "example.internal."
    error_message = "Private DNS zone must use the configured domain."
  }

  assert {
    condition     = module.dns-private-zone["test-zone"].name == "test-zone"
    error_message = "Private DNS zone must use the configured zone name."
  }

  assert {
    condition     = module.dns-private-zone["test-zone"].type == "private"
    error_message = "DNS zone must be private."
  }
}

run "dns_includes_vm_a_records" {
  command = plan

  variables {
    dns_private_zone = [{
      name       = "test-zone"
      domain     = "example.internal."
      recordsets = []
    }]
    vm_instances   = [var.test_vm]
    firewall_rules = []
    sql_instances  = []
  }

  assert {
    condition     = contains(output.dns_private_zone_recordset_keys["test-zone"], "node-1/A")
    error_message = "DNS zone must include an A record for each VM instance."
  }
}

run "dns_preserves_custom_recordsets" {
  command = plan

  variables {
    dns_private_zone = [{
      name   = "test-zone"
      domain = "example.internal."
      recordsets = [{
        name    = "localhost"
        type    = "A"
        ttl     = 300
        records = ["127.0.0.1"]
      }]
    }]
    vm_instances   = [var.test_vm]
    firewall_rules = []
    sql_instances  = []
  }

  assert {
    condition     = length(output.dns_private_zone_recordset_keys["test-zone"]) == 2
    error_message = "DNS zone must include both VM and custom recordsets."
  }

  assert {
    condition     = contains(output.dns_private_zone_recordset_keys["test-zone"], "localhost/A")
    error_message = "Custom DNS recordsets must be preserved."
  }

  assert {
    condition     = contains(output.dns_private_zone_recordset_keys["test-zone"], "node-1/A")
    error_message = "VM DNS recordsets must be included alongside custom recordsets."
  }
}
