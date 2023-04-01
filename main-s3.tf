# Create an S3 bucket for the website content
resource "aws_s3_bucket" "website" {
  bucket = "video-training-website-bucket"
}

resource "aws_s3_bucket" "website-logging-bucket" {
  bucket = "video-training-website-logging-bucket"
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

}

resource "aws_s3_bucket_acl" "website_acl" {
  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}

# Create a CloudFront distribution for the website
resource "aws_cloudfront_distribution" "website" {
  depends_on = [aws_s3_bucket.website]

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example website distribution"
  default_root_object = "index.html"

  # Configure caching behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Configure SSL/TLS
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Configure access logging
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.website-logging-bucket.bucket_regional_domain_name
    prefix          = "website/"
  }

  # Configure restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
