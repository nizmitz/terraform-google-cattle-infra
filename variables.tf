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
    ip_cidr_range = ["10.0.0.0/16"]
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

variable "waf_instance" {
  type = object({
    name         = string
    machine_type = string
    description  = string
    network_tags = list(string)
    disk_size    = number
  })

  default = {
    name         = "default"
    machine_type = "e2-micro"
    description  = "default machine"
    network_tags = ["default"]
    disk_size    = 10
  }
  description = "Specification that will be used for waf instance"
}

variable "cattle_instance" {
  type = object({
    name         = string
    machine_type = string
    description  = string
    network_tags = list(string)
    disk_size    = number
    external_ip  = bool
  })

  default = {
    name         = "default"
    machine_type = "e2-micro"
    description  = "default machine"
    network_tags = ["default"]
    disk_size    = 10
    external_ip  = false
  }
  description = "Specification that will be used for waf instance"
}

variable "sql_instance" {
  type = object({
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
  })
  default = {
    name                        = "default"
    tier                        = "db-f1-micro"
    database_version            = "POSTGRES_17"
    edition                     = "ENTERPRISE"
    availability_type           = "ZONAL"
    disk_size                   = 10
    disk_type                   = "PD_HDD"
    deletion_protection_enabled = true
    private_network             = false
    query_insights_enabled      = true
  }
  description = "Specification that will be used for sql_instance"
}
