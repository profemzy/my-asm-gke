output "asm_namespace" {
  value = kubernetes_namespace.ns-istio-system.metadata[0].name
}

output "asm_label" {
  value = local.asm_label
}