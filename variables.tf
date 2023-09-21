variable "location" {
  type    = string
  default = "Southeast Asia"
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

variable "vm_family_size" {
}

