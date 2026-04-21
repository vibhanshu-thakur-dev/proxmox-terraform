terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

resource "helm_release" "charts" {
  for_each = { for r in var.releases : r.name => r }

  name             = each.value.name
  chart            = each.value.chart
  repository       = each.value.repository
  namespace        = each.value.namespace
  version          = each.value.version
  create_namespace = each.value.create_namespace

  values = fileexists("${var.values_dir}/${each.value.name}.yaml") ? [
    file("${var.values_dir}/${each.value.name}.yaml")
  ] : []
}
