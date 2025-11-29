resource "aws_cloudwatch_log_group" "recipe_ai_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-recipe-ai-generator"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "presigned_url_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-presigned-url-generator"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_recipes_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-recipes"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "post_recipe_log_group" {
  name              = "/aws/lambda/${var.project_name}-post-recipe"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_recipe_by_id_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-recipe-by-id"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "post_comment_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-post-comment"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "post_like_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-post-like"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "post_user_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-post-user"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_users_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-users"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_user_by_id_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-user-by-id"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_user_recipes_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-user-recipes"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_user_likes_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-user-likes"
  retention_in_days = 14
}
