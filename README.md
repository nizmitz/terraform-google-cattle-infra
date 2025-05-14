# terraform-google-cattle-infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.8.0, < 7 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.this_all_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.this_ssh_external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [tls_private_key.this_cattle](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.this_waf](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.this_cattle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_image.this_waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cattle_instance"></a> [cattle\_instance](#input\_cattle\_instance) | Specification that will be used for waf instance | <pre>object({<br/>    name         = string<br/>    machine_type = string<br/>    description  = string<br/>    network_tags = list(string)<br/>    disk_size    = number<br/>    external_ip  = bool<br/>  })</pre> | <pre>{<br/>  "description": "default machine",<br/>  "disk_size": 10,<br/>  "external_ip": false,<br/>  "machine_type": "e2-micro",<br/>  "name": "default",<br/>  "network_tags": [<br/>    "default"<br/>  ]<br/>}</pre> | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | ip range that will be used for the vpc | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_os_family"></a> [os\_family](#input\_os\_family) | OS family for the instances | `string` | `"debian-12"` | no |
| <a name="input_os_project"></a> [os\_project](#input\_os\_project) | OS public project names for the instances | `string` | `"debian-cloud"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id of the project that holds the network. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the project that is hosted. | `string` | `"asia-southeast1"` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH user that will be used for all the instances | `string` | `"terraform"` | no |
| <a name="input_waf_instance"></a> [waf\_instance](#input\_waf\_instance) | Specification that will be used for waf instance | <pre>object({<br/>    name         = string<br/>    machine_type = string<br/>    description  = string<br/>    network_tags = list(string)<br/>    disk_size    = number<br/>  })</pre> | <pre>{<br/>  "description": "default machine",<br/>  "disk_size": 10,<br/>  "machine_type": "e2-micro",<br/>  "name": "default",<br/>  "network_tags": [<br/>    "default"<br/>  ]<br/>}</pre> | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone of the project that is hosted. | `string` | `"a"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
