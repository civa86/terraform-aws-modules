output "docker_ip" {
  value       = aws_instance.master.public_ip
  description = "Docker Machine IP"
}
