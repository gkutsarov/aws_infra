/*resource "kubernetes_config_map" "html_config" {
  metadata {
    name = "html-config"
  }

  data = {
    "index.html" = <<EOF
    <html>
    <body>
      <h1>HELLO WORLD!</h1>
    </body>
    </html>
    EOF
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      app = "my-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }

      spec {
        volume {
          name = "html-config"
          config_map {
            name = kubernetes_config_map.html_config.metadata[0].name
          }
        }
        container {
          name  = "nginx"
          image = "nginx"
          volume_mount {
            name = "html-config"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path = "index.html"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "myingress" {
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
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
*/