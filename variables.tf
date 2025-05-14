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

variable "ip_cidr_range" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "ip range that will be used for the vpc"
}

variable "os_project" {
  type        = string
  default     = "debian-cloud"
  description = "OS public project names for the instances"
}

variable "os_family" {
  type        = string
  default     = "debian-12"
  description = "OS family for the instances"
}

variable "ssh_user" {
  type        = string
  default     = "terraform"
  description = "SSH user that will be used for all the instances"
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
