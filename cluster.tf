locals {
  nodepools = {
    "standard-4" = {
      node_machine_type = "e2-standard-4"
      min_node_count    = 1
      max_node_count    = 3
    }
  }
  master_authorized_ranges = {
    all = "0.0.0.0/0"
  }
}

data "google_project" "project" {
  project_id = var.project_name
}

# Application cluster
module "gke_application_cluster" {
  source = "github.com/dapperlabs-platform/terraform-google-gke-cluster?ref=v0.9.4"

  project_id = var.project_name
  name       = "${var.default_region}-application"
  # STABLE for production
  release_channel           = "REGULAR"
  location                  = var.default_region
  network                   = module.gke_vpc.self_link
  subnetwork                = module.gke_vpc.subnet_self_links["${var.default_region}/gke"]
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
  default_max_pods_per_node = 100

  master_authorized_ranges = local.master_authorized_ranges
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "10.0.16.0/28"
    master_global_access    = false
  }
  labels = {
    mesh_id = "proj-${data.google_project.project.number}"
  }
  namespaces                 = []
  workload_identity_profiles = {}
}

module "gke_application_cluster-nodepools" {
  for_each                    = local.nodepools
  source                      = "github.com/dapperlabs-platform/terraform-google-gke-nodepool?ref=v0.9.1"
  project_id                  = var.project_name
  cluster_name                = module.gke_application_cluster.name
  location                    = module.gke_application_cluster.location
  name                        = each.key
  node_image_type             = "cos_containerd"
  node_machine_type           = each.value.node_machine_type
  node_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  autoscaling_config = {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  node_labels = {}

  node_tags = [
    module.gke_application_cluster.name
  ]
}

module "gke_application_cluster-firewall" {
  source      = "github.com/dapperlabs-platform/terraform-google-net-vpc-firewall-yaml?ref=v0.9.0"
  project_id  = var.project_name
  network     = module.gke_vpc.name
  config_path = "./vpc-firewall-rules/gke"
}

resource "google_compute_global_address" "ingress" {
  project      = var.project_name
  name         = "ingress-static-ip"
  address_type = "EXTERNAL"
}

module "hub_mesh" {
  source = "./hub_mesh"

  asm_gke_location = module.gke_application_cluster.location
  asm_gke_name     = module.gke_application_cluster.name
  project_name     = var.project_name
}

provider "kubernetes" {
  host                   = "https://${module.gke_application_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_application_cluster.ca_certificate)
}

data "google_client_config" "default" {}

module "asm" {
  source           = "github.com/dapperlabs-platform/terraform-asm?ref=v0.1.3"
  project_id       = var.project_name
  cluster_name     = module.gke_application_cluster.name
  cluster_location = module.gke_application_cluster.location
  enable_cni       = true
}
