terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
  backend "gcs" {
    bucket = "femi-gke-workload-identity-bucket"
    prefix = "asm"
  }
}

provider "google" {
  project = var.project_name
  region  = var.default_region
}
