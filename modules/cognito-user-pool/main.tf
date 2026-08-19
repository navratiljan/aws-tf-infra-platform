resource "aws_cognito_user_pool" "pool" {
  name = "app-user-pool"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_identity_provider" "example_provider" {
  count = var.create_google_provider ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
  }
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "app-client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = [var.frontend_url]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO", "Google"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "ens-auth"
  user_pool_id = aws_cognito_user_pool.pool.id
}