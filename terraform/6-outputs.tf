output "api_base_url_production" {
  value = aws_api_gateway_stage.production.invoke_url
}

output "api_key_free_plan" {
  value     = aws_api_gateway_api_key.free.value
  sensitive = true
}

output "api_v1_docs_main_json" {
  value = "https://${random_pet.docs_api_v1_bucket_name.id}.s3.amazonaws.com/main.json"
}
