resource "helm_release" "my_app" {
  name      = "k8s-resources"
  chart     = "${path.module}/charts/"  # Path to local chart
  namespace = "default"
} 
