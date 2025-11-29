output "flutter_web_bucket_name" {
  description = "Flutter Web用のS3バケット名"
  value       = aws_s3_bucket.flutter_web.id
}

output "flutter_web_cloudfront_distribution_id" {
  description = "Flutter Web用のCloudFront Distribution ID"
  value       = aws_cloudfront_distribution.flutter_web.id
}

output "flutter_web_cloudfront_domain_name" {
  description = "Flutter Web用のCloudFront URL"
  value       = aws_cloudfront_distribution.flutter_web.domain_name
}

output "flutter_web_url" {
  description = "Flutter WebアプリケーションのURL"
  value       = "https://${aws_cloudfront_distribution.flutter_web.domain_name}"
}
