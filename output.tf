output "mysql_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "frontend_endpoint" {
  value = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}
