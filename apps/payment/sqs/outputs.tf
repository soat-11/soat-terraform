output "create-payment-queue-dlq_url" {
  value = module.create-payment-queue.dlq_url
}

output "create-payment-queue_url" {
  value = module.create-payment-queue.queue_url
}

output "payment-paid-queue-dlq_url" {
  value = module.payment-paid-queue.dlq_url
}

output "payment-paid-queue_url" {
  value = module.payment-paid-queue.queue_url
}

output "mercado-pago-process-payment-queue-dlq_url" {
  value = module.mercado-pago-process-payment-queue.dlq_url
}

output "mercado-pago-process-payment-queue_url" {
  value = module.mercado-pago-process-payment-queue.queue_url
}

output "cancel-payment-queue-dlq_url" {
  value = module.cancel-payment-queue.dlq_url
}

output "cancel-payment-queue_url" {
  value = module.cancel-payment-queue.queue_url
}
