variable "project_id" {
  type        = string
  description = "Project id of the project that holds the network."
}

variable "region" {
  type        = string
  default     = "asia-southeast1"
  description = "Region of the project that is hosted."
}

variable "zone" {
  type        = string
  default     = "a"
  description = "Zone of the project that is hosted."
}

variable "network_configuration" {
  type = object({
    ip_cidr_range = list(string)
  })
  default = {
    ip_cidr_range = ["172.10.0.0/16"]
  }
  description = "common configuration for the VPC"
}

variable "compute_configuration" {
  type = object({
    os_project = string
    os_family  = string
    ssh_user   = string
  })
  default = {
    os_family  = "debian-12"
    os_project = "debian-cloud"
    ssh_user   = "terraform"
  }
  description = "common configuration for all compute instances"
}


variable "vm_instances" {
  type = list(object({
    name                        = string
    machine_type                = string
    description                 = optional(string)
    network_tags                = optional(list(string))
    disk_size                   = optional(number)
    nat_ip                      = optional(bool, false)
    enable_secure_boot          = optional(bool, false)
    enable_vtpm                 = optional(bool, false)
    enable_integrity_monitoring = optional(bool, false)
    enable_disk_encryption      = optional(bool, false)
  }))
  default     = []
  description = "Specification that will be used for vm instances"
}

variable "firewall_rules" {
  type = list(object({
    name          = string
    description   = optional(string)
    source_ranges = list(string)
    target_tags   = list(string)
    allow         = list(string)
  }))
  default     = []
  description = "Specification that will be used for firewall rules"
}

variable "sql_instances" {
  type = list(object({
    name                        = string
    tier                        = string
    database_version            = string
    edition                     = string
    availability_type           = string
    disk_size                   = number
    disk_type                   = string
    deletion_protection_enabled = bool
    private_network             = bool
    query_insights_enabled      = bool
    ssl_mode                    = string
    database_flags = list(object({
      name  = string
      value = string
    }))
  }))
  default     = []
  description = "Specification that will be used for sql_instances"
}

variable "dns_private_zone" {
  type = list(object({
    name   = string
    domain = string
    recordsets = list(object({
      name    = string
      type    = string
      ttl     = number
      records = list(string)
    }))
  }))
  default     = []
  description = "Specification that will be used for dns_private_zone"
}

variable "nat_configuration" {
  type = object({
    network_tier                   = optional(string, "PREMIUM")
    enable_dynamic_port_allocation = optional(bool, false)
  })
  default     = {}
  description = "Specification that will be used for nat_configuration"
}
