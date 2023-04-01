resource "aws_s3_bucket" "front_end_app" {
  bucket = "video-training-frontend-app"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::video-training-frontend-app/*"
      }
    ]
  }
POLICY
}

resource "aws_s3_bucket_acl" "front_end_app_acl" {
  bucket = aws_s3_bucket.front_end_app.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "front_end_app" {
  bucket = aws_s3_bucket.front_end_app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
