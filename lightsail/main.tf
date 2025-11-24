resource "aws_lightsail_instance" "server" {
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  tags              = var.tags

  user_data = <<-EOF
              #!/bin/bash
              # Log everything to /var/log/user_data.log
              exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              set -e
              
              echo "Starting User Data Script..."

              # 1. Setup 3GB Swap
              echo "Setting up 3GB Swap..."
              if [ ! -f /swapfile ]; then
                fallocate -l 3G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
                echo "vm.swappiness=10" >> /etc/sysctl.conf
                sysctl -p
              else
                echo "Swap already exists."
              fi

              # 2. Install Docker (Robust Method)
              echo "Installing Docker..."
              if ! command -v docker &> /dev/null; then
                curl -fsSL https://get.docker.com | sh
                systemctl start docker
                systemctl enable docker
              else
                echo "Docker already installed."
              fi

              # 3. Get Public IP with Retry
              echo "Fetching Public IP..."
              MAX_RETRIES=10
              COUNT=0
              while [ $COUNT -lt $MAX_RETRIES ]; do
                PUBLIC_IP=$(curl -s --connect-timeout 5 http://169.254.169.254/latest/meta-data/public-ipv4)
                if [[ -n "$PUBLIC_IP" ]]; then
                  echo "Public IP found: $PUBLIC_IP"
                  break
                fi
                echo "Waiting for Public IP... ($COUNT/$MAX_RETRIES)"
                sleep 5
                COUNT=$((COUNT+1))
              done

              if [[ -z "$PUBLIC_IP" ]]; then
                echo "Failed to get Public IP. Defaulting to auto-detect by wg-easy."
                # wg-easy tries to auto-detect if WG_HOST is missing, or we can omit it to let client side handle it?
                # Better to fail safe or try another service
                PUBLIC_IP=$(curl -s ifconfig.me)
              fi

              # 4. Run WG-Easy
              echo "Starting WG-Easy container..."
              # Stop existing if any
              docker stop wg-easy || true
              docker rm wg-easy || true

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

              echo "User Data Script Completed!"
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
