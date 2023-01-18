resource "aws_api_gateway_rest_api" "main" {
  name = "main"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  # triggers = {
  # NOTE: The configuration below will satisfy ordering considerations,
  #       but not pick up all future REST API changes. More advanced patterns
  #       are possible, such as using the filesha1() function against the
  #       Terraform configuration file(s) or removing the .id references to
  #       calculate a hash against whole resources. Be aware that using whole
  #       resources will show a difference after the initial implementation.
  #       It will stabilize to only change when resources change afterwards.
  # redeployment = sha1(jsonencode([
  #   aws_api_gateway_integration.goodbye_integration,
  #   aws_api_gateway_integration.hello_integration,
  #   aws_api_gateway_integration.welcome_integration
  # ]))

  # `aws_api_gateway_integration.<resource_name>` using the whole resource itself,
  # instead of just the `id`.connection. `id` does not change unless the entire resource is recreated
  # }

  # Also adding a timestamp within `redeployment` items can trigger a redeployment
  # variables = {
  #  deployed_at = "${timestamp()}"
  # }
  # }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_api_gateway_stage" "production" {
  # To avoid issue:
  # "CloudWatch Logs role ARN must be set in account settings to enable logging"
  depends_on = [
    aws_api_gateway_account.main
  ]
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "v1"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name              = "/aws/api-gw/${aws_api_gateway_rest_api.main.name}"
  retention_in_days = 14
}
