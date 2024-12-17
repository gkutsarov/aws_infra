resource "helm_release" "metrics_server" {
  name  = "metrics-server"
  chart = "metrics-server" # Chart name
  namespace  = "default"   # Deploying into the default namespace

  repository = "https://kubernetes-sigs.github.io/metrics-server/" # Official Kubernetes SIG repository
  version    = "3.10.0"                                            # Specify the chart version you want

  values = [
    <<EOF
replicaCount: 2
args:
  - --kubelet-insecure-tls
EOF
  ]

  #depends_on = [kubernetes_namespace.kube_system] # Ensures namespace exists before deploying
}
