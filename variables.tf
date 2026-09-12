variable "regions" {
  type = map(object({
    location = string
    vm_count = number
  }))
}