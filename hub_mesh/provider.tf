terraform {
  required_version = ">=1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

# Provider
provider "google" {
  project = var.project_name
}
provider "google-beta" {
  project = var.project_name
}
