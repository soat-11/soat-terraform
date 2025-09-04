resource "kubernetes_secret" "soat_api_secret" {
  metadata {
    name = "soat-api-secret"
  }
  type = "Opaque"
  data = {
    DB_NAME                      = var.db_name
    DB_USER                      = var.db_user
    DB_PASSWORD                  = var.db_password
    DB_PORT                      = var.db_port
    DB_HOST                      = var.db_host
    APP_PORT                     = var.app_port
    APP_BASE_URL                 = var.app_base_url
    PAYMENT_ACCESS_TOKEN         = var.payment_access_token
    PAYMENT_API_URL              = var.payment_api_url
    PAYMENT_USER_ID              = var.payment_user_id
    PAYMENT_POS_ID               = var.payment_pos_id
    WEBHOOK_SECRET_SIGNATURE_KEY = var.webhook_secret_signature_key
    WEBHOOK_API_URL              = var.webhook_api_url
  }
}
