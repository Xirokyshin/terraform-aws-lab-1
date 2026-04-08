provider "aws" {
  region = var.aws_region
}

module "base_label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  namespace   = "uni"
  environment = "dev"
  name        = "app"
}

# 2. Створення таблиць бази даних
module "dynamodb_courses" {
  source     = "./modules/dynamodb"
  table_name = "courses"
  context    = module.base_label.context
}

module "dynamodb_authors" {
  source     = "./modules/dynamodb"
  table_name = "authors"
  context    = module.base_label.context
}

data "archive_file" "get_all_authors_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/get-all-authors"
  output_path = "${path.module}/functions/get-all-authors.zip"
}
resource "aws_iam_role" "get_all_authors_role" {
  name = "${module.base_label.id}-get-all-authors-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_policy" "get_all_authors_policy" {
  name = "${module.base_label.id}-get-all-authors-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:Scan", Resource = module.dynamodb_authors.table_arn }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "get_all_authors_attach" {
  role       = aws_iam_role.get_all_authors_role.name
  policy_arn = aws_iam_policy.get_all_authors_policy.arn
}
resource "aws_lambda_function" "get_all_authors" {
  filename         = data.archive_file.get_all_authors_zip.output_path
  function_name    = "${module.base_label.id}-get-all-authors"
  role             = aws_iam_role.get_all_authors_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_all_authors_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_authors.table_name } }
}

data "archive_file" "get_all_courses_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/get-all-courses"
  output_path = "${path.module}/functions/get-all-courses.zip"
}
resource "aws_iam_role" "get_all_courses_role" {
  name = "${module.base_label.id}-get-all-courses-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_policy" "get_all_courses_policy" {
  name = "${module.base_label.id}-get-all-courses-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:Scan", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "get_all_courses_attach" {
  role       = aws_iam_role.get_all_courses_role.name
  policy_arn = aws_iam_policy.get_all_courses_policy.arn
}
resource "aws_lambda_function" "get_all_courses" {
  filename         = data.archive_file.get_all_courses_zip.output_path
  function_name    = "${module.base_label.id}-get-all-courses"
  role             = aws_iam_role.get_all_courses_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_all_courses_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_courses.table_name } }
}

data "archive_file" "get_course_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/get-course"
  output_path = "${path.module}/functions/get-course.zip"
}
data "archive_file" "save_course_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/save-course"
  output_path = "${path.module}/functions/save-course.zip"
}
data "archive_file" "update_course_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/update-course"
  output_path = "${path.module}/functions/update-course.zip"
}
data "archive_file" "delete_course_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/delete-course"
  output_path = "${path.module}/functions/delete-course.zip"
}

resource "aws_iam_role" "course_mutations_role" {
  name = "${module.base_label.id}-course-mutations-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_policy" "course_mutations_policy" {
  name = "${module.base_label.id}-course-mutations-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"], Resource = module.dynamodb_courses.table_arn }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "course_mutations_attach" {
  role       = aws_iam_role.course_mutations_role.name
  policy_arn = aws_iam_policy.course_mutations_policy.arn
}

resource "aws_lambda_function" "get_course" {
  filename         = data.archive_file.get_course_zip.output_path
  function_name    = "${module.base_label.id}-get-course"
  role             = aws_iam_role.course_mutations_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_course_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_courses.table_name } }
}
resource "aws_lambda_function" "save_course" {
  filename         = data.archive_file.save_course_zip.output_path
  function_name    = "${module.base_label.id}-save-course"
  role             = aws_iam_role.course_mutations_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.save_course_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_courses.table_name } }
}
resource "aws_lambda_function" "update_course" {
  filename         = data.archive_file.update_course_zip.output_path
  function_name    = "${module.base_label.id}-update-course"
  role             = aws_iam_role.course_mutations_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.update_course_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_courses.table_name } }
}
resource "aws_lambda_function" "delete_course" {
  filename         = data.archive_file.delete_course_zip.output_path
  function_name    = "${module.base_label.id}-delete-course"
  role             = aws_iam_role.course_mutations_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.delete_course_zip.output_base64sha256
  environment { variables = { REGION = var.aws_region, TABLE_NAME = module.dynamodb_courses.table_name } }
}