variable "helm_namespace" {}
variable "helm_repository" {}
variable "chart_version" {
	default = "0.16.0-alpha.0"
}

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
