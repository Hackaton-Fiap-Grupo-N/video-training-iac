data "aws_secretsmanager_secret" "db_password" {
  name       = "db-password"
  depends_on = [aws_secretsmanager_secret_version.db_password]
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id  = data.aws_secretsmanager_secret.db_password.id
  depends_on = [aws_secretsmanager_secret_version.db_password]
}

resource "aws_db_instance" "default" {
  depends_on = [aws_secretsmanager_secret_version.db_password]

  identifier           = "production-db"
  instance_class       = "db.t2.micro"
  storage_type         = "gp2"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  db_name              = "video-training"
  port                 = 3306
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  username = "dbadmin"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
