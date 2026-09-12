variable "regions" {
  type = map(object({
    location = string
    vm_count = number
  }))
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}