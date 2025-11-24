variable "zone_id" {
  description = "The Zone ID where the record will be created"
  type        = string
}

# Optional variables for the single dynamic record
variable "create_dynamic_record" {
  description = "Whether to create a dynamic record passed via variables"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the record (e.g., 'www')"
  type        = string
  default     = ""
}

variable "value" {
  description = "The value of the record (e.g., IP address)"
  type        = string
  default     = ""
}

variable "type" {
  description = "The type of the record (e.g., 'A', 'CNAME')"
  type        = string
  default     = "A"
}

variable "proxied" {
  description = "Whether the record is proxied by Cloudflare"
  type        = bool
  default     = false
}

variable "ttl" {
  description = "The TTL of the record"
  type        = number
  default     = 1 # Auto
}
