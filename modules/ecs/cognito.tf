resource "aws_cognito_user_pool" "default" {
  name = local.name
  tags = var.tags
}

resource "aws_cognito_user_pool_client" "default" {
  depends_on                           = [aws_lb.ingress]
  name                                 = local.name
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid"]
  callback_urls                        = ["https://${aws_lb.ingress.dns_name}/oauth2/idpresponse"]
  generate_secret                      = true
  supported_identity_providers         = ["COGNITO"]
  user_pool_id                         = aws_cognito_user_pool.default.id
}

resource "aws_cognito_user_pool_domain" "default" {
  domain       = local.name
  user_pool_id = aws_cognito_user_pool.default.id
}
