terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_record" "record" {
  count = var.create_dynamic_record ? 1 : 0

  zone_id = var.zone_id
  name    = var.name
  value   = var.value
  type    = var.type
  proxied = var.proxied
  ttl     = var.ttl
}
