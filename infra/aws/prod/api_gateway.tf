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

# Presigned URLエンドポイント
resource "aws_api_gateway_resource" "presigned_url_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "presigned-url"
}

resource "aws_api_gateway_method" "presigned_url_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.presigned_url_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "presigned_url_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.presigned_url_resource.id
  http_method = aws_api_gateway_method.presigned_url_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.presigned_url_generator.invoke_arn
}

# /recipes リソース (GET と POST で共有) - 既存のリソース名を維持
resource "aws_api_gateway_resource" "post_recipe_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "recipes"
}

# GET /recipes
resource "aws_api_gateway_method" "recipes_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.post_recipe_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recipes_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_recipes.invoke_arn
}

# POST /recipes
resource "aws_api_gateway_method" "post_recipe_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.post_recipe_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_recipe_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.post_recipe_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_recipe.invoke_arn
}

# OPTIONS /recipes (CORS)
resource "aws_api_gateway_method" "recipes_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.post_recipe_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recipes_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "recipes_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "recipes_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_options_method.http_method
  status_code = aws_api_gateway_method_response.recipes_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /recipes/{recipeId} リソース
resource "aws_api_gateway_resource" "recipe_by_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.post_recipe_resource.id
  path_part   = "{recipeId}"
}

# GET /recipes/{recipeId}
resource "aws_api_gateway_method" "recipe_by_id_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recipe_by_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_recipe_by_id.invoke_arn
}

# OPTIONS /recipes/{recipeId} (CORS)
resource "aws_api_gateway_method" "recipe_by_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recipe_by_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "recipe_by_id_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "recipe_by_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_options_method.http_method
  status_code = aws_api_gateway_method_response.recipe_by_id_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "main_deployment" {
  depends_on = [
    aws_api_gateway_integration.recipe_ai_integration,
    aws_api_gateway_integration.presigned_url_integration,
    aws_api_gateway_integration.recipes_get_integration,
    aws_api_gateway_integration.post_recipe_integration,
    aws_api_gateway_integration.recipes_options_integration,
    aws_api_gateway_integration.recipe_by_id_get_integration,
    aws_api_gateway_integration.recipe_by_id_options_integration
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
