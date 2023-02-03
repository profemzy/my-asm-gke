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

resource "null_resource" "exec_asm_gke_mesh" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/scripts/mesh.sh"
    environment = {
      CLUSTER  = data.google_container_cluster.asm_cluster.name
      LOCATION = data.google_container_cluster.asm_cluster.location
      PROJECT  = var.project_name
    }
  }
  triggers = {
    build_number = "${timestamp()}"
    script_sha1  = sha1(file("${path.module}/scripts/mesh.sh")),
  }
}
