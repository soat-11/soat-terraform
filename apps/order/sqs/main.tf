module "order-created-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "order-created-queue-dlq"
  queue_name        = "order-created-queue"
  max_receive_count = 3

  tags = {
    Name = "order-created-queue"
  }
}

