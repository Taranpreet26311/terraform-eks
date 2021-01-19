variable "aws_region" {
  default = "us-west-1"
}

variable "cluster-name" {
  default = "terraform-eks-cluster"
  type    = string
}

variable "node_class" {
  default = ["t3.large"]
  type    = list
}

variable "namespace" {
  default = "default"
  type    = string
}
