# type will be injected into Accept request header e.g.
#  Accept = "application/json"
variable "file" {
  description = "'type' allowed values: yaml, json"
  type = object({
    url = string
    type = string
    path = string
  })
}