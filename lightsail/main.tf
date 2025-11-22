resource "aws_lightsail_instance" "server" {
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  tags              = var.tags
}

resource "aws_lightsail_static_ip" "ip" {
  name = "${var.instance_name}-static-ip"
}

resource "aws_lightsail_static_ip_attachment" "attach" {
  static_ip_name = aws_lightsail_static_ip.ip.name
  instance_name  = aws_lightsail_instance.server.name
}

