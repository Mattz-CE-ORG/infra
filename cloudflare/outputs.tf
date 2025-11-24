output "record_hostname" {
  value = var.create_dynamic_record ? cloudflare_record.record[0].hostname : null
}

output "record_id" {
  value = var.create_dynamic_record ? cloudflare_record.record[0].id : null
}
