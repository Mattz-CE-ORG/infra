locals {
  existing_dns_records = {
    "algo" = {
      name    = "algo"
      value   = "54.178.57.74"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "763bb365458c51196f96fbb8608a60f0"
    }
    "root" = {
      name    = "arsserver.com"
      value   = "35.89.111.150"
      type    = "A"
      proxied = false
      ttl     = 120
      id      = "aaaa5fb1aa7235b3e9318c2a349ad6b3"
    }
    "dmm" = {
      name    = "dmm"
      value   = "13.231.213.23"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "9a28933e8829ee72a0062bc589e1bb74"
    }
    "ls" = {
      name    = "ls"
      value   = "52.192.175.29"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "01ace829465ea45ae591bff2898f56c5"
    }
    "mc" = {
      name    = "mc"
      value   = "34.94.60.232"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "e2553b744a8cb2498e698bcc7d02d6d7"
    }
    "ohio" = {
      name    = "ohio"
      value   = "3.17.177.62"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "17c9f50fd6755bc00cfdad41608e7399"
    }
    "phoenix" = {
      name    = "phoenix"
      value   = "52.90.69.134"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "aa1ebf69ba149e1dec7a1886f3e992d7"
    }
    "r630" = {
      name    = "r630"
      value   = "34.233.32.57"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "ae0dbdb9a8b74818be55a9ea40725e48"
    }
    "rb_virginia" = {
      name    = "rb.virginia"
      value   = "52.203.136.188"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "6a2a02e72f8d1c2cc157dd495acfd936"
    }
    "tokyo" = {
      name    = "tokyo"
      value   = "35.72.130.136"
      type    = "A"
      proxied = false
      ttl     = 1
      id      = "d1f4c41252ab317148b831fc5d0bcae3"
    }
    "virginia" = {
      name    = "virginia"
      value   = "52.203.136.188"
      type    = "A"
      proxied = false
      ttl     = 120
      id      = "14bdb01a74c33489cccba6df4ce81a46"
    }
  }
}

resource "cloudflare_record" "existing_records" {
  for_each = local.existing_dns_records

  zone_id = var.zone_id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  proxied = each.value.proxied
  ttl     = each.value.ttl
}

