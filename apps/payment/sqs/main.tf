module "create-payment-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "create-payment-queue-dlq"
  queue_name        = "create-payment-queue"
  max_receive_count = 3



  tags = {
    Name = "create-payment-queue"
  }
}

module "payment-paid-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "payment-paid-queue-dlq"
  queue_name        = "payment-paid-queue"
  max_receive_count = 3

  queue_config = {
    visibility_timeout_seconds = 120
  }

  tags = {
    Name = "payment-paid-queue"
  }
}

module "mercado-pago-process-payment-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "mercado-pago-process-payment-queue-dlq"
  queue_name        = "mercado-pago-process-payment-queue"
  max_receive_count = 3

  queue_config = {
    visibility_timeout_seconds = 120
  }

  tags = {
    Name = "mercado-pago-process-payment-queue"
  }
}

module "cancel-payment-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "cancel-payment-queue-dlq"
  queue_name        = "cancel-payment-queue"
  max_receive_count = 3

  tags = {
    Name = "cancel-payment-queue"
  }
}
