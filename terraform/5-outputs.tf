output "api_base_url_staging" {
  value = aws_apigatewayv2_stage.staging.invoke_url
}

output "api_base_url_production" {
  value = aws_apigatewayv2_stage.production.invoke_url
}
