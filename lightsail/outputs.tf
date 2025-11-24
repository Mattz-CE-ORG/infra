output "static_ip" {
  description = "The static IP address allocated to the Lightsail instance"
  value       = aws_lightsail_static_ip.ip.ip_address
}

output "instance_name" {
  description = "The name of the Lightsail instance"
  value       = aws_lightsail_instance.server.name
}

output "username" {
  description = "The username for the instance"
  value       = aws_lightsail_instance.server.username
}

output "wg_web_ui" {
  description = "URL for WireGuard Web UI"
  value       = "http://${aws_lightsail_static_ip.ip.ip_address}:51821"
}
