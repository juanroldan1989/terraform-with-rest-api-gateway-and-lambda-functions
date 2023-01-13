# REST API Gateway - Lambda authorization workflow

1. The client calls a method on an API Gateway API method, passing a bearer token or request parameters.

2. API Gateway checks whether a Lambda authorizer is configured for the method. If it is, API Gateway calls the Lambda function.

3. The Lambda function authenticates the caller by means such as the following:

- Calling out to an OAuth provider to get an OAuth access token.

- Calling out to a SAML provider to get a SAML assertion.

- Generating an IAM policy based on the request parameter values.

- Retrieving credentials from a database.

4. If the call succeeds, the Lambda function grants access by returning an output object containing at least an IAM policy and a principal identifier.

5. API Gateway evaluates the policy.

- If access is denied, API Gateway returns a suitable HTTP status code, such as 403 ACCESS_DENIED.

- If access is allowed, API Gateway executes the method. If caching is enabled in the authorizer settings, API Gateway also caches the policy so that the Lambda authorizer function doesn't need to be invoked again.

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/custom-auth-workflow.png" width="100%" />

## REST API Gateway - Features implemented

- Routes integration with Lambda Functions ✅
- Lambda Authorizer implemented for specific endpoints ✅
- API Versioning through URI path ✅
- CI/CD: API Deployment through Github Actions -> Terraform -> AWS ✅
- Usage Plans.
- API Keys.
- Rate Limits.
- API Load Testing.
- Throttle Configuration.

## REST APIs vs HTTP APIs

- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-routes.html

- REST APIs and HTTP APIs are both RESTful API products.

- REST APIs support more features than HTTP APIs, while HTTP APIs are designed with minimal features so that they can be offered at a lower price.

- Choose REST APIs if you need features such as API keys, per-client throttling, request validation, AWS WAF integration, or private API endpoints.

- Choose HTTP APIs if you don't need the features included with REST APIs.

## REST API Gateway implementation through Terraform

- Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api

- Resource: `aws_api_gateway_rest_api`

- Manages an API Gateway REST API.

- The REST API can be configured via importing an OpenAPI specification in the `body` argument (with other arguments serving as overrides) OR

- via other `Terraform resources` to manage the resources (`aws_api_gateway_resource` resource), methods (`aws_api_gateway_method` resource), integrations (`aws_api_gateway_integration` resource), etc. of the REST API.

- Once the `REST API` is configured, the `aws_api_gateway_deployment` resource can be used along with the `aws_api_gateway_stage` resource to **publish the REST API.**

- With a REST API we can apply **Usage Plans, Rate Limits and Throttle Configuration.**

- Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api

```
Resource: aws_apigatewayv2_api
Manages an Amazon API Gateway Version 2 API.
```

Note:

- Amazon **API Gateway Version 2** resources are used for creating and deploying **WebSocket and HTTP APIs.**

- To create and deploy **REST APIs**, use Amazon **API Gateway Version 1** resources.

## REST API Gateway - Lambda Authorizer

https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html

- A Lambda authorizer (formerly known as a custom authorizer) is an API Gateway feature that uses a `Lambda function to control access to your API`.

- A Lambda authorizer is useful if you want to implement a `custom` authorization scheme that uses a bearer token authentication strategy such as OAuth or SAML, or that uses request parameters to determine the caller's identity.

- When a client makes a request to one of your API's methods, API Gateway calls your Lambda authorizer, which takes the caller's **identity as input** and returns an **IAM policy as output.**

### Testing Lambda Authorizer (Console)

- AWS Reference for 401 errors: https://aws.amazon.com/premiumsupport/knowledge-center/api-gateway-401-error-lambda-authorizer/

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/1.png" width="100%" />

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/2.png" width="100%" />

## Testing for token-based Lambda authorizers (Postman)

If `Lambda Event Payload` is set as `Token`, then check the `Token Source` value. The `Token Source` value must be used as the `request header` in calls to your API:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/3.png" width="100%" />

### Testing - Authorization Header with `allow` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/4.png" width="100%" />

### Testing - Authorization Header with `deny` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/5.png" width="100%" />

### Testing - Authorization Header not included in request

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/6.png" width="100%" />

## REST API Gateway - Stage resource

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage

- Manages an API Gateway Stage. A stage is a named reference to a deployment, which can be done via the `aws_api_gateway_deployment` resource.

## REST API Gateway - Base Path

Authorization logic applied through `Lambda Authorizer` function:

```ruby
% curl https://<api-id>.execute-api.<region>.amazonaws.com/v1

{ "message" : "Missing Authentication Token" }
```

## REST API Gateway - Hello Endpoint (public)

```ruby
# 3-rest-api-gateway-integration-hello-lambda.tf
...

resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}
```

```ruby
curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/hello

{ "message" : "Hello, world!" }
```

## REST API Gateway - Goodbye Endpoint (private)

```ruby
# 3-rest-api-gateway-integration-goodbye-lambda.tf
...

resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.goodbye_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.main.id
}
```

```ruby
$ curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/goodbye

{ "message" : "Unauthorized" }
```

```ruby
$ curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/goodbye \
-H "Authorization: allow"

{ "message" : "Goodbye!" }
```

## Deployment - Terraform - Random Error

```ruby
$ terraform apply
```

```
Error creating API Gateway Deployment: BadRequestException: The REST API doesn't contain any methods
```

Temporarly solution: run `terraform apply` again.

TODO: research and fix this.
