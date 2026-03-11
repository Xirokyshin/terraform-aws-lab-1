module "table_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = var.context
  name    = var.table_name
}

resource "aws_dynamodb_table" "this" {
  name         = module.table_label.id
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}