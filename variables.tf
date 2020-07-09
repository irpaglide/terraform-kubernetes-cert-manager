variable "helm_namespace" {}
variable "helm_repository" {}
variable "chart_version" {}

variable "values" {
  default = ""
  type    = "string"
}

variable "letsencrypt_email" {}

variable "azure_service_principal_id" { 
default = ""
}

variable "azure_client_secret" {
	default = ""
}

variable "cloudflare_apikey" {
	default = ""
}

variable "azure_subscription_id" {
	default = ""
}

variable "azure_tenant_id" {
	default = ""
}

variable "azure_resource_group_name" { 
default = ""
}

variable "azure_zone_name" {
	default = ""
}

variable "cloudflare_email" {
	default = ""
}

variable "solver" {
	default = "cloudflare"
}

variable "dependencies" {
  type = "list"
}
