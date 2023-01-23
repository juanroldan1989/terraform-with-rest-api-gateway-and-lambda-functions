output "api_base_url_production" {
  value = aws_api_gateway_stage.production.invoke_url
}

output "api_key_free_plan" {
  value     = aws_api_gateway_api_key.free.value
  sensitive = true
}
