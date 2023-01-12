resource "aws_api_gateway_resource" "goodbye_resource" {
  path_part   = "goodbye"
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "goodbye_method" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.goodbye_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.main.id
}

resource "aws_api_gateway_integration" "goodbye_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.goodbye_resource.id
  http_method             = aws_api_gateway_method.goodbye_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.goodbye.invoke_arn
}

resource "aws_lambda_permission" "api_gw_goodbye_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.goodbye.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}
