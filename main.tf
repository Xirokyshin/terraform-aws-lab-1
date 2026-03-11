provider "aws" {
  region = var.aws_region
}

# 1. Головний генератор імен
module "base_label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  namespace   = "uni"
  environment = "dev"
  name        = "app"
}

# 2. Створення таблиць
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

# 3. Підготовка ZIP-архіву Лямбди (тепер з папки functions)
data "archive_file" "get_all_authors_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/get-all-authors"
  output_path = "${path.module}/functions/get-all-authors.zip"
}

# 4. IAM Роль та Політика
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

# 5. Створення Лямбда-функції
resource "aws_lambda_function" "get_all_authors" {
  filename         = data.archive_file.get_all_authors_zip.output_path
  function_name    = "${module.base_label.id}-get-all-authors"
  role             = aws_iam_role.get_all_authors_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_all_authors_zip.output_base64sha256

  environment {
    variables = {
      REGION     = var.aws_region
      TABLE_NAME = module.dynamodb_authors.table_name
    }
  }
}