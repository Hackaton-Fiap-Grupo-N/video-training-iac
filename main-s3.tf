resource "aws_s3_bucket" "front_end_app" {
  bucket = "video-training-frontend-app"
  acl    = "public-read"
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
}
POLICY
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
