variable "name_prefix" {
  type = string
}

variable "cron" {
  type = string
}

variable "container_definition" {
  type = any
}

variable "efs_volumes" {
  type = list(object({
    name           = string
    file_system_id = string
  }))
  default = []
}

variable "log_retention_in_days" {
  type    = number
  default = 7
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "subnets" {
  type = list(string)
}