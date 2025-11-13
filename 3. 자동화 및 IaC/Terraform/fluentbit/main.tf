# 1. aws configure env
# 2. sso login
# 3. kube config context switch
# 4. terraform apply

variable "env" {
  type = string
  default = "dev"
}

variable "eks_cluster_name" {
  type = map(string)
  default = {
    dev  = ""
    stg  = ""
    prod = ""
  }
}

variable "create_oss" {
  type = map(bool)
  default = {
    dev  = true
    stg  = false
    prod = false
  }
}

locals {
  fluentbit = var.create_oss["fluentbit"]
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name[var.env]
}

provider "helm" {
  kubernetes = {
    host        = data.aws_eks_cluster.eks_cluster.endpoint
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "fluentbit" {
    count = local.fluentbit ? 1 : 0
    namespace = "logarchive"
    name = "fluent-bit"
    chart = "fluent-bit"
    version = "0.48.5"
    repository = "https://fluent.github.io/helm-charts"
    create_namespace = true
    # force_update = true
    values = [
        templatefile(
        "${path.module}/helm/values-dev.yaml",
            {
                env             = var.env
                repository      = ""
                image_tag       = "fluent-bit-3.1.6"
            }
        )
    ]

}