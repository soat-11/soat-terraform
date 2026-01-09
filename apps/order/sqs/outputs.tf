output "sqs_order_created_url" {
  value = module.order-created-queue.queue_url
}

output "sqs_order_created_arn" {
  value = module.order-created-queue.queue_arn
}

