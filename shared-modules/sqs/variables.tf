variable "dlq_name" {
  description = "The name of the dead letter queue"
  type        = string
}

variable "queue_name" {
  description = "The name of the queue"
  type        = string
}

variable "max_receive_count" {
  description = "The maximum number of receive count"
  type        = number
  default     = 3
}

variable "dlq_config" {
  description = "The configuration of the dead letter queue"
  type        = map(any)
  default     = {}
}

variable "queue_config" {
  description = "The configuration of the queue"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "The tags of the queue"
  type        = map(any)
  default     = {}
}
