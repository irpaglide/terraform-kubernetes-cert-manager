variable "helm_namespace" {}
variable "helm_repository" {}
variable "chart_version" {}

variable "values" {
  default = ""
  type    = string
}

variable "letsencrypt_email" {}

variable "cloudflare_apikey" {
	default = ""
}

variable "cloudflare_email" {
	default = ""
}

variable "dependencies" {
  type = list
}
