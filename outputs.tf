output "courses_table_name" {
  description = "Name of the courses DynamoDB table"
  value       = module.dynamodb_courses.table_name
}

output "authors_table_name" {
  description = "Name of the authors DynamoDB table"
  value       = module.dynamodb_authors.table_name
}

output "api_base_url" {
  description = "Base API URL"
  value       = aws_api_gateway_stage.dev.invoke_url
}