output "courses_table_name" {
  description = "Name of the courses DynamoDB table"
  value       = module.dynamodb_courses.table_name
}

output "authors_table_name" {
  description = "Name of the authors DynamoDB table"
  value       = module.dynamodb_authors.table_name
}