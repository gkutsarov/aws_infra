resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  create_namespace = true

 values = [
    templatefile("${path.module}/values.yaml.tpl", {
      username = kubernetes_secret.argocd_repo_secret.data["username"]
      password = kubernetes_secret.argocd_repo_secret.data["token"]
    })
  ]
}

resource "helm_release" "argocd-apps" {
  depends_on = [helm_release.argocd]
  name = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argocd-apps"
  namespace = "argocd"

  values = [
    <<EOT
    applications:
      app-of-apps:
        namespace: argocd
        project: default
        source:
          repoURL: https://github.com/gkutsarov/app_of_apps
          targetRevision: main
          path: bootstrap
        destination:
          server: https://kubernetes.default.svc
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
    EOT
  ]
}

/*data "external" "update_konfig" {
  program = [
    "bash",
    "-c",
    "aws eks update-kubeconfig --region us-west-2 --name my_eks_cluster --role-arn arn:aws:iam::905418146175:role/eks_admin_role"
  ]
}

data "external" "argocd_alb_dns_name" {
  program = [
    "bash",
    "-c",
    "kubectl get ingress argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | jq -R '{\"hostname\": .}'"
  ]
}

resource "argocd_application" "bootstrap" {
  metadata {
    name = "bootstrap-apps"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url = "https://github.com/gkutsarov/app_of_apps"
      target_revision = "main"
      path = "bootstrap"
    }

    destination {
      server = "http://kubernetes.default.svc"
      namespace = "argocd"
    }

    sync_policy {
      automated {
        prune = true # Removed from Git = removed from the cluster
        self_heal = true  # Auto fixes drift between cluster state and repo
      }
    }
  }
}*/




