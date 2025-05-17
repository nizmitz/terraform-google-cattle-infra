# terraform-google-cattle-infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.8.0, < 7 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.35.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 6.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_global_address.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_address) | resource |
| [google_compute_address.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.this_all_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.this_ssh_external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_sql_database_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.this_cattle](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.this_waf](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_image.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cattle_instance"></a> [cattle\_instance](#input\_cattle\_instance) | Specification that will be used for waf instance | <pre>object({<br/>    name         = string<br/>    machine_type = string<br/>    description  = string<br/>    network_tags = list(string)<br/>    disk_size    = number<br/>    external_ip  = bool<br/>  })</pre> | <pre>{<br/>  "description": "default machine",<br/>  "disk_size": 10,<br/>  "external_ip": false,<br/>  "machine_type": "e2-micro",<br/>  "name": "default",<br/>  "network_tags": [<br/>    "default"<br/>  ]<br/>}</pre> | no |
| <a name="input_compute_configuration"></a> [compute\_configuration](#input\_compute\_configuration) | common configuration for all compute instances | <pre>object({<br/>    os_project = string<br/>    os_family  = string<br/>    ssh_user   = string<br/>  })</pre> | <pre>{<br/>  "os_family": "debian-12",<br/>  "os_project": "debian-cloud",<br/>  "ssh_user": "terraform"<br/>}</pre> | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | common configuration for the VPC | <pre>object({<br/>    ip_cidr_range = list(string)<br/>  })</pre> | <pre>{<br/>  "ip_cidr_range": [<br/>    "10.0.0.0/16"<br/>  ]<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id of the project that holds the network. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the project that is hosted. | `string` | `"asia-southeast1"` | no |
| <a name="input_sql_instance"></a> [sql\_instance](#input\_sql\_instance) | Specification that will be used for sql\_instance | <pre>object({<br/>    name                        = string<br/>    tier                        = string<br/>    database_version            = string<br/>    edition                     = string<br/>    availability_type           = string<br/>    disk_size                   = number<br/>    disk_type                   = string<br/>    deletion_protection_enabled = bool<br/>    private_network             = bool<br/>    query_insights_enabled      = bool<br/>  })</pre> | <pre>{<br/>  "availability_type": "ZONAL",<br/>  "database_version": "POSTGRES_17",<br/>  "deletion_protection_enabled": true,<br/>  "disk_size": 10,<br/>  "disk_type": "PD_HDD",<br/>  "edition": "ENTERPRISE",<br/>  "name": "default",<br/>  "private_network": false,<br/>  "query_insights_enabled": true,<br/>  "tier": "db-f1-micro"<br/>}</pre> | no |
| <a name="input_waf_instance"></a> [waf\_instance](#input\_waf\_instance) | Specification that will be used for waf instance | <pre>object({<br/>    name         = string<br/>    machine_type = string<br/>    description  = string<br/>    network_tags = list(string)<br/>    disk_size    = number<br/>  })</pre> | <pre>{<br/>  "description": "default machine",<br/>  "disk_size": 10,<br/>  "machine_type": "e2-micro",<br/>  "name": "default",<br/>  "network_tags": [<br/>    "default"<br/>  ]<br/>}</pre> | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone of the project that is hosted. | `string` | `"a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sql_password"></a> [sql\_password](#output\_sql\_password) | n/a |
| <a name="output_sql_properties"></a> [sql\_properties](#output\_sql\_properties) | n/a |
<!-- END_TF_DOCS -->
