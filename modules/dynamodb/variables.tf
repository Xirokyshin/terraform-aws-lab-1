variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "context" {
  description = "Context from the main label module"
  type        = any
  default     = {}
}