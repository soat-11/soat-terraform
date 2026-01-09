output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}

output "queue_url" {
  value = aws_sqs_queue.queue.url
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "queue_arn" {
  value = aws_sqs_queue.queue.arn
}
