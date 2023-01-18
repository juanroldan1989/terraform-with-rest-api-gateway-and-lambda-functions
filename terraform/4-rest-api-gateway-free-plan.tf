resource "aws_api_gateway_api_key" "free" {
  name = "free_api_key"
}

resource "aws_api_gateway_usage_plan" "free" {
  name         = "free"
  description  = "Free Subscription"
  product_code = "FREE_CODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.production.stage_name
  }

  quota_settings {
    limit  = 200    # Maximum number of requests that can be made in a given time period.
    offset = 2      # Number of requests subtracted from the given limit in the initial time period.
    period = "WEEK" # Time period in which the limit applies. Valid values are "DAY", "WEEK" or "MONTH"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_usage_plan_key" "free" {
  key_id        = aws_api_gateway_api_key.free.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.free.id
}
