resource "aws_api_gateway_rest_api" "main_api" {
  name        = "${var.project_name}-prod-api"
  description = "本番環境用のAPIゲートウェイ"
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_rest_api.main_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "recipe_ai_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "generate-recipe"
}

resource "aws_api_gateway_method" "recipe_ai_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.recipe_ai_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recipe_ai_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_ai_resource.id
  http_method = aws_api_gateway_method.recipe_ai_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.recipe_ai_generator.invoke_arn
}

resource "aws_api_gateway_deployment" "main_deployment" {
  depends_on = [
    aws_api_gateway_integration.recipe_ai_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.main_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main_stage" {
  deployment_id = aws_api_gateway_deployment.main_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  stage_name    = "prod"

  variables = {
    "environment" = "production"
    "api_version" = "v1"
  }

  lifecycle {
    create_before_destroy = true
  }
}
