resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "default" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "default" {
  private_key      = tls_private_key.default.private_key_pem
  certificate_body = tls_self_signed_cert.default.cert_pem
}
