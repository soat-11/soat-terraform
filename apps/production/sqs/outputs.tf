output "sqs_payment_confirmed_url" {
  value = module.payment-confirmed-queue.queue_url
}

output "sqs_production_started_url" {
  value = module.production-started-queue.queue_url
}

output "sqs_production_ready_url" {
  value = module.production-ready-queue.queue_url
}

output "sqs_production_withdrawn_url" {
  value = module.production-withdrawn-queue.queue_url
}

