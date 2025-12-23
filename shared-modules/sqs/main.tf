locals {

  sqs_defaults = {
    delay_seconds              = 0
    visibility_timeout_seconds = 30
    message_retention_seconds  = 86400
    receive_wait_time_seconds  = 0
  }


  dlq_config = merge(local.sqs_defaults, var.dlq_config)


  queue_config = merge(local.sqs_defaults, var.queue_config)
}


resource "aws_sqs_queue" "dlq" {
  name                       = var.dlq_name
  delay_seconds              = local.dlq_config.delay_seconds
  visibility_timeout_seconds = local.dlq_config.visibility_timeout_seconds
  message_retention_seconds  = lookup(local.dlq_config, "message_retention_seconds", 1209600) # 14 dias para DLQ
  receive_wait_time_seconds  = local.dlq_config.receive_wait_time_seconds

  tags = merge(
    { Name = var.dlq_name },
    var.tags
  )
}


resource "aws_sqs_queue" "queue" {
  name                       = var.queue_name
  delay_seconds              = local.queue_config.delay_seconds
  visibility_timeout_seconds = local.queue_config.visibility_timeout_seconds
  message_retention_seconds  = local.queue_config.message_retention_seconds
  receive_wait_time_seconds  = local.queue_config.receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(
    { Name = var.queue_name },
    var.tags
  )

  depends_on = [aws_sqs_queue.dlq]
}
