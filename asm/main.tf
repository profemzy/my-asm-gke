locals {
  asm_label = var.asm_channel == "stable" ? "asm-managed-stable" : var.asm_channel == "rapid" ? "asm-managed-rapid" : "asm-managed"
}

data "google_container_cluster" "asm_cluster" {
  name     = var.asm_gke_name
  location = var.asm_gke_location
}

module "asm-gke1" {
  source       = "./module/"
  project_id   = var.project_name
  asm_channel  = var.asm_channel
  cni_enabled  = var.cni_enabled
  cluster_name = data.google_container_cluster.asm_cluster.name
  location     = data.google_container_cluster.asm_cluster.location
}
