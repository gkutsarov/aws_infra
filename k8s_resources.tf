resource "kubernetes_service_account" "vpc_cni_service_account_custom" {
  depends_on = [module.eks]
  metadata {
    name = "vpc_cni_service_account_custom"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "vpc_cni_service_account_custom"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cni_irsa_role.iam_role_arn
    }
  }
}


resource "kubernetes_config_map" "app1_config" {
  depends_on = [module.eks]
  metadata {
    name = "app1config"
  }

  data = {
    "index.html" = "<html><body><h1>Deployment 1</h1></body></html>"
    "nginx.conf" = <<EOF
    server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF
  }
}

resource "kubernetes_service" "service1" {
  depends_on = [module.eks]
  metadata {
    name = "service1"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app1.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "app1" {
  depends_on = [module.eks]
  metadata {
    name = "app1"
    labels = {
      app = "my-app1"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "my-app1"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app1"
        }
      }
      spec {
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.app1_config.metadata.0.name
          }
        }
        container {
          image = "nginx"
          name = "my-app1"
          port {
            container_port = 80
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/usr/share/nginx/html"
            sub_path = "index.html"
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path = "nginx.conf"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "app2_config" {
  depends_on = [module.eks]
  metadata {
    name = "app2config"
  }

  data = {
    "index.html" = "<html><body><h1>Deployment 2</h1></body></html>"
    "nginx.conf" = <<EOF
    server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF
  }
}

resource "kubernetes_service" "service2" {
  depends_on = [module.eks]
  metadata {
    name = "service2"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app2.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "app2" {
  depends_on = [module.eks]
  metadata {
    name = "app2"
    labels = {
      app = "my-app2"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "my-app2"
      }
    }
    template {
      metadata {
        labels = {
          app = "my-app2"
        }
      }
      spec {
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.app2_config.metadata.0.name
          }
        }
        container {
          image = "nginx"
          name = "my-app1"
          port {
            container_port = 80
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/usr/share/nginx/html"
            sub_path = "index.html"
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path = "nginx.conf"
          }
        }
      }
    }
  }
}

/*resource "kubernetes_ingress_v1" "myingress" {
  depends_on = [module.eks]
  wait_for_load_balancer = true
  metadata {
    name = "example-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/ingress.class"       = "alb"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/subnets"             = join(", ", [
        data.aws_subnet.public_subnet_1.id,
        data.aws_subnet.public_subnet_2.id,
        data.aws_subnet.public_subnet_3.id
      ])
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{
        HTTP = 80
      }])
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path     = "/app1"
          path_type = "Prefix" # Required in networking.k8s.io/v1
          backend {
            service {
              name = "service1"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path     = "/app2"
          path_type = "Prefix" # Required in networking.k8s.io/v1
          backend {
            service {
              name = "service2"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}*/

