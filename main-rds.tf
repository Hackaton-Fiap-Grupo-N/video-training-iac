resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.private_subnets

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.name
  username               = var.username
  password               = aws_secretsmanager_secret_version.db_password.secret_string
  port                   = var.port
  identifier             = var.identifier
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.hackaton_task.id]
}
