resource "aws_s3_bucket" "recipe_images" {
  bucket = "${var.project_name}-recipe-images"
}

resource "aws_s3_bucket_public_access_block" "recipe_images" {
  bucket = aws_s3_bucket.recipe_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "recipe_images" {
  bucket = aws_s3_bucket.recipe_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.recipe_images.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.recipe_images]
}

resource "aws_s3_bucket_cors_configuration" "recipe_images" {
  bucket = aws_s3_bucket.recipe_images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "flutter_web" {
  bucket = var.flutter_web_bucket_name
}

resource "aws_s3_bucket_public_access_block" "flutter_web" {
  bucket = aws_s3_bucket.flutter_web.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "flutter_web" {
  bucket = aws_s3_bucket.flutter_web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.flutter_web.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.flutter_web]
}

resource "aws_s3_bucket_website_configuration" "flutter_web" {
  bucket = aws_s3_bucket.flutter_web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
