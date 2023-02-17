data "google_container_cluster" "asm_cluster" {
  name     = var.asm_gke_name
  location = var.asm_gke_location
}

resource "google_gke_hub_membership" "asm_gke_membership" {
  membership_id = var.asm_gke_name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${data.google_container_cluster.asm_cluster.id}"
    }
  }
  provider = google-beta
}

resource "google_gke_hub_feature" "feature" {
  provider = google-beta

  name = "servicemesh"
  location = "global"
}
