output "mysql_endpoint" {
  value = aws_db_instance.production_db.endpoint
}

output "ecr_repository_api_endpoint" {
  value = aws_ecr_repository.video_training_api.repository_url
}

output "frontend_endpoint" {
  value = aws_s3_bucket_website_configuration.front_end_app.website_endpoint
}
