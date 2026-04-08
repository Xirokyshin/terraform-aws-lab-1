# 1. Створюємо API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name        = "${module.base_label.id}-api"
  description = "API Gateway for University App"
}

# 2. Створюємо ресурс (шлях) /courses
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "courses"
}

# 3. Налаштовуємо метод GET для шляху /courses
resource "aws_api_gateway_method" "get_all_courses" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

# 4. Інтегруємо цей GET-запит із Лямбдою get-all-courses
resource "aws_api_gateway_integration" "get_all_courses_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_all_courses.http_method
  # AWS вимагає використовувати POST для внутрішнього виклику Лямбди, навіть якщо зовнішній метод GET
  integration_http_method = "POST" 
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_all_courses.invoke_arn
}

# 5. Даємо дозвіл API Gateway викликати цю Лямбду
resource "aws_lambda_permission" "apigw_get_all_courses" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_courses.function_name
  principal     = "apigateway.amazonaws.com"
  
  # Дозволяємо виклик тільки з нашого конкретного API
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ==========================================
# Маршрут: POST /courses (Збереження курсу)
# ==========================================

# 1. Створюємо метод POST для вже існуючого ресурсу /courses
resource "aws_api_gateway_method" "save_course" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.courses.id  # Використовуємо існуючий ресурс!
  http_method   = "POST"
  authorization = "NONE"
}

# 2. Інтегруємо POST-запит із Лямбдою save-course
resource "aws_api_gateway_integration" "save_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.save_course.http_method
  integration_http_method = "POST" 
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.save_course.invoke_arn
}

# 3. Дозвіл API Gateway викликати Лямбду save_course
resource "aws_lambda_permission" "apigw_save_course" {
  statement_id  = "AllowAPIGatewayInvokePOSTCourses"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ==========================================
# Ресурс (шлях): /courses/{id}
# ==========================================
resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.courses.id # Батьківський шлях - /courses
  path_part   = "{id}" # Фігурні дужки означають динамічний параметр
}

# ------------------------------------------
# Метод: GET /courses/{id} (Отримати курс)
# ------------------------------------------
resource "aws_api_gateway_method" "get_course" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.get_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_course.invoke_arn
}

resource "aws_lambda_permission" "apigw_get_course" {
  statement_id  = "AllowAPIGatewayInvokeGETCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ------------------------------------------
# Метод: PUT /courses/{id} (Оновити курс)
# ------------------------------------------
resource "aws_api_gateway_method" "update_course" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.update_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_course.invoke_arn
}

resource "aws_lambda_permission" "apigw_update_course" {
  statement_id  = "AllowAPIGatewayInvokePUTCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ------------------------------------------
# Метод: DELETE /courses/{id} (Видалити курс)
# ------------------------------------------
resource "aws_api_gateway_method" "delete_course" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_course_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.delete_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_course.invoke_arn
}

resource "aws_lambda_permission" "apigw_delete_course" {
  statement_id  = "AllowAPIGatewayInvokeDELETECourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ==========================================
# Маршрут: GET /authors (Отримати всіх авторів)
# ==========================================
resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "authors"
}

resource "aws_api_gateway_method" "get_all_authors" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_all_authors_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_all_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_all_authors.invoke_arn
}

resource "aws_lambda_permission" "apigw_get_all_authors" {
  statement_id  = "AllowAPIGatewayInvokeGETAuthors"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_authors.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}


# ==========================================
# ПУБЛІКАЦІЯ АРІ (Deployment та Stage)
# ==========================================

# 1. Розгортаємо наш API (Deployment)
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Вказуємо, що розгортання має чекати створення всіх інтеграцій
  depends_on = [
    aws_api_gateway_integration.get_all_courses_integration,
    aws_api_gateway_integration.save_course_integration,
    aws_api_gateway_integration.get_course_integration,
    aws_api_gateway_integration.update_course_integration,
    aws_api_gateway_integration.delete_course_integration,
    aws_api_gateway_integration.get_all_authors_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Створюємо стадію (Stage), наприклад "dev" або "v1"
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev" # Це слово буде в нашому URL
}