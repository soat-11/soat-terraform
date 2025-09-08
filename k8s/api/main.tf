# resource "kubernetes_horizontal_pod_autoscaler_v2" "soat_nginx_hpa" {
#   metadata {
#     name      = "${var.app_name}-nginx-hpa"
#     namespace = "ingress-nginx"
#   }

#   spec {
#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "ingress-nginx-controller"
#     }

#     min_replicas = 1
#     max_replicas = 8

#     metric {
#       type = "Resource"
#       resource {
#         name = "cpu"
#         target {
#           type                = "Utilization"
#           average_utilization = 50
#         }
#       }
#     }

#     metric {
#       type = "Resource"
#       resource {
#         name = "memory"
#         target {
#           type                = "Utilization"
#           average_utilization = 50
#         }
#       }
#     }
#   }
# }



