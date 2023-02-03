variable "project_name" {
  type = string
}

variable "asm_gke_name" {
  type = string
}

variable "asm_gke_location" {
  type = string
}

variable "asm_channel" {
  type    = string
  default = "regular"
}

variable "cni_enabled" {
  type    = string
  default = "true"
}