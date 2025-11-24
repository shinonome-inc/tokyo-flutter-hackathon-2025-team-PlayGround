resource "aws_cloudwatch_log_group" "recipe_ai_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-recipe-ai-generator"
  retention_in_days = 14
}
