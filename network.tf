locals {
  region_configs = {
    "${var.default_region}" = {
      subnets = {
        gke = {
          ip_cidr_range               = "10.0.0.0/20"    # 4096 addresses
          pods_secondary_ip_range     = "172.16.0.0/15"  # 131070 addresses
          services_secondary_ip_range = "192.168.0.0/19" # 8190 addresses
        }
      }
      nat_ip_count = 1
    }
  }
}

module "gke_vpc" {
  source     = "github.com/dapperlabs-platform/terraform-google-net-vpc?ref=v0.9.0"
  project_id = var.project_name
  name       = "gke-application-cluster-vpc"
  subnets = flatten(
    [for region, value in local.region_configs :
      [for name, subnet in value.subnets : {
        ip_cidr_range = subnet.ip_cidr_range
        name          = name
        region        = region
        secondary_ip_range = {
          pods     = subnet.pods_secondary_ip_range
          services = subnet.services_secondary_ip_range
        }
      }]
  ])
}
