resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  create_namespace = true

 values = [
    <<EOT
    global:
      domain: ""  # Leave it blank to let AWS ALB assign the domain
    configs:
      params:
        server.insecure: true
    server:
      ingress:
        enabled: true
        annotations:
          alb.ingress.kubernetes.io/scheme: internet-facing
          alb.ingress.kubernetes.io/ingress.class: alb
          alb.ingress.kubernetes.io/target-type: ip
          alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
        ingressClassName: alb
        hosts:
          - "*"  # You can also keep it as "*" or specific hostnames like argocd.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
        tls: []
    EOT
  ]
}




