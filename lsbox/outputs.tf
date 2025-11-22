output "static_ip" {
  description = "The static IP address allocated to the Lightsail instance"
  value       = aws_lightsail_static_ip.main.ip_address
}

output "instance_name" {
  description = "The name of the Lightsail instance"
  value       = aws_lightsail_instance.main.name
}

output "username" {
  description = "The username for the instance"
  value       = aws_lightsail_instance.main.username
}

