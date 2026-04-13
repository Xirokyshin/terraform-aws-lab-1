# =======================================================
# 1. ОСНОВНИЙ SNS TOPIC (Для API та Slack у Франкфурті)
# =======================================================
resource "aws_sns_topic" "alerts" {
  name = "${module.base_label.id}-alerts-topic"
}

resource "aws_sns_topic_subscription" "alerts_email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "max.tom2777@gmail.com" 
}

# =======================================================
# 2. БІЛІНГ (Спеціальний SNS та Alarm у Вірджинії)
# =======================================================
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_sns_topic" "billing_alerts" {
  provider = aws.us_east_1
  name     = "${module.base_label.id}-billing-topic"
}

resource "aws_sns_topic_subscription" "billing_email_sub" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = "max.tom2777@gmail.com" # Твоя пошта
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm_final" {
  provider            = aws.us_east_1
  alarm_name          = "${module.base_label.id}-billing-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"
  statistic           = "Maximum"
  threshold           = "1.0"
  alarm_description   = "Сповіщення про витрати > $1"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

# =======================================================
# 3. АЛАРМ ДЛЯ API (5XX Errors) ТА КАСТОМНА МЕТРИКА
# =======================================================
resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "${module.base_label.id}-api-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Помилка 5XX в API Gateway"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ApiName = aws_api_gateway_rest_api.this.name
  }
}

resource "aws_cloudwatch_log_metric_filter" "course_created" {
  name           = "CourseCreatedCounter"
  pattern        = "\"Course saved successfully\""
  log_group_name = "/aws/lambda/${aws_lambda_function.save_course.function_name}"

  metric_transformation {
    name      = "NewCoursesCount"
    namespace = "MyApplication"
    value     = "1" 
  }
}

# =======================================================
# 4. ІНТЕГРАЦІЯ ЗІ SLACK
# =======================================================
resource "aws_lambda_function" "slack_notifier" {
  filename      = "functions/slack-notifier.zip"
  function_name = "${module.base_label.id}-slack-notifier"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

resource "aws_sns_topic_subscription" "slack_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn
}

resource "aws_lambda_permission" "allow_sns_to_slack" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

# =======================================================
# 5. РОЛЬ ДЛЯ ЛЯМБДИ SLACK
# =======================================================
resource "aws_iam_role" "lambda_exec" {
  name = "${module.base_label.id}-lambda-slack-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}