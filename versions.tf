terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8.0, < 7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"

    }
  }
}

provider "google" {
  default_labels = {
    type = "terraform"

  }
  region = var.region
  zone   = "${var.region}-${var.zone}"
}
