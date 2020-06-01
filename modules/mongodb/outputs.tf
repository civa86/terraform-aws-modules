output "db_url" {
  value       = aws_lb.mongodb.dns_name
  description = "Database URL"
}
