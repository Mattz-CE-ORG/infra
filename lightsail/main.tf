resource "aws_lightsail_instance" "server" {
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  tags              = var.tags

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # 1. Setup 3GB Swap
              echo "Setting up 3GB Swap..."
              fallocate -l 3G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab
              echo "vm.swappiness=10" >> /etc/sysctl.conf
              sysctl -p

              # 2. Install Docker
              echo "Installing Docker..."
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              # 3. Run WG-Easy (WireGuard + UI)
              # Get Public IP
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              
              echo "Starting WG-Easy..."
              docker run -d \
                --name=wg-easy \
                -e WG_HOST=$PUBLIC_IP \
                -e PASSWORD='${var.wg_password}' \
                -v ~/.wg-easy:/etc/wireguard \
                -p 51820:51820/udp \
                -p 51821:51821/tcp \
                --cap-add=NET_ADMIN \
                --cap-add=SYS_MODULE \
                --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
                --sysctl="net.ipv4.ip_forward=1" \
                --restart unless-stopped \
                ghcr.io/wg-easy/wg-easy

              echo "Done!"
              EOF
}

resource "aws_lightsail_instance_public_ports" "server" {
  instance_name = aws_lightsail_instance.server.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "udp"
    from_port = 51820
    to_port   = 51820
  }

  port_info {
    protocol  = "tcp"
    from_port = 51821
    to_port   = 51821
  }
}

resource "aws_lightsail_static_ip" "ip" {
  name = "${var.instance_name}-static-ip"
}

resource "aws_lightsail_static_ip_attachment" "attach" {
  static_ip_name = aws_lightsail_static_ip.ip.name
  instance_name  = aws_lightsail_instance.server.name
}
