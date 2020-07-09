# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
# and
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-473091030
# Make sure to add this null_resource.dependency_getter to the `depends_on`
# attribute to all resource(s) that will be constructed first within this
# module:
resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = "${join(",", var.dependencies)}"
  }

  lifecycle {
    ignore_changes = [
      triggers["my_dependencies"],
    ]
  }
}

resource "null_resource" "apply_crds" {
  triggers = {
    version = var.chart_version
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v${var.chart_version}/cert-manager.crds.yaml"
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "helm_release" "cert_manager" {
  depends_on = ["null_resource.dependency_getter", "null_resource.apply_crds"]
  name       = "cert-manager"
  repository = var.helm_repository
  chart      = "cert-manager"
  version    = "v${var.chart_version}"
  namespace  = var.helm_namespace

  values = [
    var.values
  ]
}

resource "kubernetes_secret" "cloudflare_secret" {
  metadata {
    name      = "cloudflare-api-key"
    namespace = var.helm_namespace
  }

  data = {
    apikey = var.cloudflare_apikey
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "local_file" "issuer_letsencrypt_staging" {
  content = templatefile("${path.module}/config/issuer-letsencrypt-staging.yaml",
    letsencrypt_email            = var.letsencrypt_email
    cloudflare_api_key_secret = kubernetes_secret.cloudflare_secret.metadata.0.name)"

  filename = "${path.module}/issuer-letsencrypt-staging.yaml"
}


resource "null_resource" "issuer_letsencrypt_staging" {
  triggers = {
    hash = sha256(local_file.issuer_letsencrypt_staging.content)
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.issuer_letsencrypt_staging.filename}"
  }

  depends_on = [
    null_resource.dependency_getter,
    helm_release.cert_manager,
    local_file.issuer_letsencrypt_staging
  ]
}

resource "local_file" "issuer_letsencrypt" {
  content = templatefile("${path.module}/config/issuer-letsencrypt.yaml",
    letsencrypt_email             = var.letsencrypt_email
    cloudflare_api_key_secret     = kubernetes_secret.cloudflare_secret.metadata.0.name)
    filename = "${path.module}/issuer-letsencrypt.yaml"
}


resource "null_resource" "issuer_letsencrypt" {
  triggers = {
    hash = sha256(local_file.issuer_letsencrypt.content)
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.issuer_letsencrypt.filename}"
  }

  depends_on = [
    null_resource.dependency_getter,
    helm_release.cert_manager,
    local_file.issuer_letsencrypt_staging
  ]
}

# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
resource "null_resource" "dependency_setter" {
  # Part of a hack for module-to-module dependencies.
  # https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
  # List resource(s) that will be constructed last within the module.
  depends_on = [
    helm_release.cert_manager
  ]
}
