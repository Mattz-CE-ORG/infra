variable "instance_name" {
  description = "The name of the Lightsail instance"
  type        = string
}

variable "blueprint_id" {
  description = "The ID for a virtual private server image (e.g., ubuntu_24_04)"
  type        = string
  default     = "ubuntu_24_04"
}

variable "bundle_id" {
  description = "The bundle of specification information (e.g., nano_3_0)"
  type        = string
  default     = "nano_3_0"
}

variable "availability_zone" {
  description = "The Availability Zone in which to create your instance"
  type        = string
  default     = "us-east-1a"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

