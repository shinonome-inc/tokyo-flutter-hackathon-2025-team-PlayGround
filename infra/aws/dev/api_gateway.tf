resource "aws_api_gateway_rest_api" "main_api" {
  name        = "${var.project_name}-dev-api"
  description = "開発環境用のAPIゲートウェイ"
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

# GET メソッドレスポンス設定
resource "aws_api_gateway_method_response" "recipes_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# GET メソッド integration response
resource "aws_api_gateway_integration_response" "recipes_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.recipes_get_method.http_method
  status_code = aws_api_gateway_method_response.recipes_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.recipes_get_integration]
}

# POST メソッドレスポンス設定
resource "aws_api_gateway_method_response" "post_recipe_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.post_recipe_method.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST メソッド integration response
resource "aws_api_gateway_integration_response" "post_recipe_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.post_recipe_resource.id
  http_method = aws_api_gateway_method.post_recipe_method.http_method
  status_code = aws_api_gateway_method_response.post_recipe_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.post_recipe_integration]
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

# GET /recipes/{recipeId} method response
resource "aws_api_gateway_method_response" "recipe_by_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# GET /recipes/{recipeId} integration response
resource "aws_api_gateway_integration_response" "recipe_by_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method
  status_code = aws_api_gateway_method_response.recipe_by_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.recipe_by_id_get_integration]
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

# /recipes/{recipeId}/comments リソース
resource "aws_api_gateway_resource" "comments_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.recipe_by_id_resource.id
  path_part   = "comments"
}

# POST /recipes/{recipeId}/comments
resource "aws_api_gateway_method" "comments_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.comments_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "comments_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_comment.invoke_arn
}

# POST /recipes/{recipeId}/comments method response
resource "aws_api_gateway_method_response" "comments_post_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_post_method.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST /recipes/{recipeId}/comments integration response
resource "aws_api_gateway_integration_response" "comments_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_post_method.http_method
  status_code = aws_api_gateway_method_response.comments_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.comments_post_integration]
}

# OPTIONS /recipes/{recipeId}/comments (CORS)
resource "aws_api_gateway_method" "comments_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.comments_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "comments_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "comments_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "comments_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_options_method.http_method
  status_code = aws_api_gateway_method_response.comments_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /recipes/{recipeId}/likes リソース
resource "aws_api_gateway_resource" "likes_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.recipe_by_id_resource.id
  path_part   = "likes"
}

# POST /recipes/{recipeId}/likes
resource "aws_api_gateway_method" "likes_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.likes_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "likes_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_like.invoke_arn
}

# POST /recipes/{recipeId}/likes method response
resource "aws_api_gateway_method_response" "likes_post_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_post_method.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST /recipes/{recipeId}/likes integration response
resource "aws_api_gateway_integration_response" "likes_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_post_method.http_method
  status_code = aws_api_gateway_method_response.likes_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.likes_post_integration]
}

# OPTIONS /recipes/{recipeId}/likes (CORS)
resource "aws_api_gateway_method" "likes_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.likes_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "likes_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "likes_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "likes_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.likes_resource.id
  http_method = aws_api_gateway_method.likes_options_method.http_method
  status_code = aws_api_gateway_method_response.likes_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /users リソース
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "users"
}

# POST /users
resource "aws_api_gateway_method" "users_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_user.invoke_arn
}

# POST /users method response
resource "aws_api_gateway_method_response" "users_post_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_post_method.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST /users integration response
resource "aws_api_gateway_integration_response" "users_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_post_method.http_method
  status_code = aws_api_gateway_method_response.users_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.users_post_integration]
}

# GET /users
resource "aws_api_gateway_method" "users_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_users.invoke_arn
}

# GET /users method response
resource "aws_api_gateway_method_response" "users_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# GET /users integration response
resource "aws_api_gateway_integration_response" "users_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_get_method.http_method
  status_code = aws_api_gateway_method_response.users_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.users_get_integration]
}

# OPTIONS /users (CORS)
resource "aws_api_gateway_method" "users_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "users_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "users_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "users_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.users_options_method.http_method
  status_code = aws_api_gateway_method_response.users_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /users/{userId} リソース
resource "aws_api_gateway_resource" "user_by_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{userId}"
}

# GET /users/{userId}
resource "aws_api_gateway_method" "user_by_id_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.user_by_id_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_by_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user_by_id.invoke_arn
}

# GET /users/{userId} method response
resource "aws_api_gateway_method_response" "user_by_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# GET /users/{userId} integration response
resource "aws_api_gateway_integration_response" "user_by_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_get_method.http_method
  status_code = aws_api_gateway_method_response.user_by_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.user_by_id_get_integration]
}

# OPTIONS /users/{userId} (CORS)
resource "aws_api_gateway_method" "user_by_id_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.user_by_id_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_by_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "user_by_id_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "user_by_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_by_id_resource.id
  http_method = aws_api_gateway_method.user_by_id_options_method.http_method
  status_code = aws_api_gateway_method_response.user_by_id_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /users/{userId}/recipes リソース
resource "aws_api_gateway_resource" "user_recipes_resource" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  parent_id   = aws_api_gateway_resource.user_by_id_resource.id
  path_part   = "recipes"
}

# GET /users/{userId}/recipes
resource "aws_api_gateway_method" "user_recipes_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.user_recipes_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_recipes_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user_recipes.invoke_arn
}

# GET /users/{userId}/recipes method response
resource "aws_api_gateway_method_response" "user_recipes_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# GET /users/{userId}/recipes integration response
resource "aws_api_gateway_integration_response" "user_recipes_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_get_method.http_method
  status_code = aws_api_gateway_method_response.user_recipes_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.user_recipes_get_integration]
}

# OPTIONS /users/{userId}/recipes (CORS)
resource "aws_api_gateway_method" "user_recipes_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.user_recipes_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_recipes_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "user_recipes_options_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "user_recipes_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.user_recipes_resource.id
  http_method = aws_api_gateway_method.user_recipes_options_method.http_method
  status_code = aws_api_gateway_method_response.user_recipes_options_response.status_code

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
    aws_api_gateway_integration_response.recipes_get_integration_response,
    aws_api_gateway_integration_response.post_recipe_integration_response,
    aws_api_gateway_integration_response.recipes_options_integration_response,
    aws_api_gateway_integration.recipe_by_id_get_integration,
    aws_api_gateway_integration_response.recipe_by_id_get_integration_response,
    aws_api_gateway_integration.recipe_by_id_options_integration,
    aws_api_gateway_integration_response.recipe_by_id_options_integration_response,
    aws_api_gateway_integration.comments_post_integration,
    aws_api_gateway_integration_response.comments_post_integration_response,
    aws_api_gateway_integration.comments_options_integration,
    aws_api_gateway_integration_response.comments_options_integration_response,
    aws_api_gateway_integration.likes_post_integration,
    aws_api_gateway_integration_response.likes_post_integration_response,
    aws_api_gateway_integration.likes_options_integration,
    aws_api_gateway_integration_response.likes_options_integration_response,
    aws_api_gateway_integration.users_post_integration,
    aws_api_gateway_integration_response.users_post_integration_response,
    aws_api_gateway_integration.users_get_integration,
    aws_api_gateway_integration_response.users_get_integration_response,
    aws_api_gateway_integration.users_options_integration,
    aws_api_gateway_integration_response.users_options_integration_response,
    aws_api_gateway_integration.user_by_id_get_integration,
    aws_api_gateway_integration_response.user_by_id_get_integration_response,
    aws_api_gateway_integration.user_by_id_options_integration,
    aws_api_gateway_integration_response.user_by_id_options_integration_response,
    aws_api_gateway_integration.user_recipes_get_integration,
    aws_api_gateway_integration_response.user_recipes_get_integration_response,
    aws_api_gateway_integration.user_recipes_options_integration,
    aws_api_gateway_integration_response.user_recipes_options_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.main_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main_stage" {
  deployment_id = aws_api_gateway_deployment.main_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  stage_name    = "dev"

  variables = {
    "environment" = "development"
    "api_version" = "v1"
  }

  lifecycle {
    create_before_destroy = true
  }
}
