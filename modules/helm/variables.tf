variable "releases" {
  description = "Helm charts to install"
  type = list(object({
    name             = string
    chart            = string
    repository       = string
    namespace        = optional(string, "default")
    version          = optional(string, null)
    create_namespace = optional(bool, true)
  }))
  default = []
}

variable "values_dir" {
  description = "Directory containing per-chart values files named <chart-name>.yaml"
  type        = string
}
