terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.12.0, < 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.12.0, < 8"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
  }
}

provider "google" {
  default_labels = {
    type = "terraform"

  }
  region                = var.region
  zone                  = "${var.region}-${var.zone}"
  user_project_override = true
}

provider "google-beta" {
  region = var.region
  zone   = "${var.region}-${var.zone}"
}
