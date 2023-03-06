# REST API Gateway implementation

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/custom-auth-workflow.png" width="100%" />

1. [Core Features](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#core-features)
2. [API Documentation](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-documentation)
3. [AWS Lambda Authorization workflow](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#aws-lambda-authorization-worfklow)
4. [API Components built through Terraform](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-components-built-through-terraform)
5. [API Versioning through URI path](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-versioning-through-uri-path)
6. [API Configuration (rate limiting & throttling)](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-configuration-rate-limiting--throttling)
7. [API Testing](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-testing)
8. [CI/CD (Github Actions -> Terraform -> AWS)](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#cicd-github-actions---terraform---aws)
9. [Observability, Error Tracking & Cost Monitoring](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#observability-error-tracking--cost-monitoring)
10. [REST APIs vs HTTP APIs](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#rest-apis-vs-http-apis)
11. [API Development Lifecycle](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#api-development-lifecycle)
12. [Further improvements](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions#further-improvements)

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/load-test-report.png" width="100%" />

# Core Features

REST API should contain 3 endpoints:

1. `hello` is a **public** endpoint. All requests are delivered into `hello` Lambda function.

2. `goodbye` is a **private** endpoint. Access validated with `Authorization: <token>` presence in request header via `Lambda Authorizer` function. Validated requests are delivered into `goodbye` Lambda function.

3. `welcome` is a **private** endpoint. Access validated through `x-api-key` presence in request header. Validated requests are delivered into `welcome` Lambda function.

# API Documentation

`OpenAPI Specification` (formerly Swagger Specification) is an API description format for REST APIs:

- https://github.com/qct/swagger-example/blob/master/README.md#introduction-to-openapi-specification
- https://swagger.io/blog/api-documentation/what-is-api-documentation-and-why-it-matters/
- https://swagger.io/docs/specification/paths-and-operations/

## Static API Docs page

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/swagger-api-docs.png" width="100%" />

1. Swagger / OpenAPI `YAML` documentation file (format easier to read & maintain) created following standard guidelines: https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/blob/main/terraform/docs/api/v1/main.yaml

2. `YAML` file converted into `JSON` (since `Swagger UI` script requires a `JSON` file):

```ruby
docs/api/v1% brew install yq
docs/api/v1% yq -o=json eval main.yaml > main.json
```

3. `JSON` file can be accessed through:

   3.a. `Github repository` itself as: https://raw.githubusercontent.com/github_username/terraform-with-rest-api-gateway-and-lambda-functions/main/docs/api/v1/main.yaml or

   3.b. `S3 bucket` that will contain `main.yml`. Bucket created and file uploaded through Terraform.

   3.c. Terraform `output` command will show this value under `api_v1_docs_main_json` variable.

- Both file accessibility options available within this repository.

4. `static` API Documentation `standalone` HTML page generated within `docs/api/v1` folder in repository: https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/installation.md#plain-old-htmlcssjs-standalone

5. Within `static` API Documentation page, replace `url` value with your own `JSON` file's URL from point `3` above:

```ruby
...
    <script>
      window.onload = () => {
        window.ui = SwaggerUIBundle({
          // url: "https://<api-id>.execute-api.<region>.amazonaws.com/main.json",
          dom_id: '#swagger-ui',
...
```

6. A `static website` can also be hosted within `S3 Bucket`: https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html

- To upload files `aws sync` command is recommended. E.g.: `aws s3 sync docs/api/v1 s3://$YOUR_BUCKET_NAME`

# AWS Lambda Authorization worfklow

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

## REST API Gateway - Lambda Authorizer

https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html

- A Lambda authorizer (formerly known as a custom authorizer) is an API Gateway feature that uses a `Lambda function to control access to your API`.

- A Lambda authorizer is useful if you want to implement a `custom` authorization scheme that uses a bearer token authentication strategy such as OAuth or SAML, or that uses request parameters to determine the caller's identity.

- When a client makes a request to one of your API's methods, API Gateway calls your Lambda authorizer, which takes the caller's **identity as input** and returns an **IAM policy as output.**

# API Components built through Terraform

- REST API Gateway implemented via Terraform (Infrastructure as Code)

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

## REST API Gateway - `base` path

Authorization logic applied through `Lambda Authorizer` function:

```ruby
% curl https://<api-id>.execute-api.<region>.amazonaws.com/v1

{ "message" : "Missing Authentication Token" }
```

## REST API Gateway - `hello` endpoint (`public`)

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

## REST API Gateway - `goodbye` endpoint (`private` with `token`)

Authorization logic applied through `Lambda Authorizer` function:

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

## REST API Gateway - `welcome` endpoint (`private` with `API_KEY`)

Authorization logic applied through `API_KEY`:

```ruby
# 3-rest-api-gateway-integration-goodbye-lambda.tf
...

resource "aws_api_gateway_method" "welcome_method" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.goodbye_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}
```

```ruby
$ curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/welcome

{ "message" : "Forbidden" }
```

```ruby
$ curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/welcome \
-H "x-api-key: XXXXXXXXXX"

{ "message" : "Welcome :)" }
```

## REST API Gateway - Alternative scenario: `API Key` provided as URL `parameter`

https://aws.amazon.com/blogs/compute/accepting-api-keys-as-a-query-string-in-amazon-api-gateway/

**How API Gateway handles API keys**

- API Gateway supports API keys sent as headers in a request.
  It does not support API keys sent as a query string parameter. API Gateway only accepts requests over HTTPS, which means that the request is encrypted.
- When sending API keys as query string parameters, there is still a risk that URLs are logged in plaintext by the client sending requests.

**API Gateway has two settings to accept API keys:**

1. Header: The request contains the values as the X-API-Key header. API Gateway then validates the key against a usage plan.
2. Authorizer: The authorizer includes the API key as part of the authorization response. Once API Gateway receives the API key as part of the response, it validates it against a usage plan.

**Long term considerations**

- This temporary solution enables developers to migrate APIs to API Gateway and maintain query string-based API keys. While this solution does work, it does not follow best practices.

- In addition to security, there is also a cost factor. Each time the client request contains an API key, the custom authorizer AWS Lambda function will be invoked, increasing the total amount of Lambda invocations you are billed for.

# API Versioning through URI path

- Versioning achieved through Terraform `stage` resource.

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage

- Manages an API Gateway Stage. A stage is a named reference to a deployment, which can be done via the `aws_api_gateway_deployment` resource.

```ruby
resource "aws_api_gateway_stage" "production" {
  # To avoid issue:
  # "CloudWatch Logs role ARN must be set in account settings to enable logging"
  depends_on = [
    aws_api_gateway_account.main
  ]
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "v1"

```

# API Configuration (rate limiting & throttling)

**Limit Exceeded (429 Throthling Error Response)**

- Configuration applied for `welcome` endpoint via `FREE` Usage Plan:

```ruby
# terraform/4-rest-api-gateway-free-plan.tf

  quota_settings {
    limit  = 10     # Maximum number of requests that can be made in a given time period.
    offset = 2      # Number of requests subtracted from the given limit in the initial time period.
    period = "WEEK" # Time period in which the limit applies. Valid values are "DAY", "WEEK" or "MONTH"
  }
```

- After exceeding **weekly** limit of **10 requests**:

```ruby
$ curl https://<api-id>.execute-api.<region>.amazonaws.com/v1/welcome \
-H "x-api-key: XXXXXXXXXX"

{"message":"Limit Exceeded"}
```

- AWS CloudWatch Logs showing error:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/limit-exceeded.png" width="100%" />

# API Testing

Testing is conducted on 3 steps within Github Actions workflow:

1. Lambda Functions (Unit testing) - [Hello Lambda Function](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/blob/main/terraform/hello/tests/unit.test.js)
2. API Testing (Integration) - [Welcome Lambda Function](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/blob/main/terraform/welcome/tests/integration.test.sh)
3. API Testing (Load) - [Welcome Lambda Function](https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/blob/main/terraform/welcome/tests/load_test.yaml)

## API Load Testing with Artillery

**Artillery** used for load testing and gathering results on different endpoints.

- https://www.artillery.io/docs/guides/getting-started/installing-artillery

- https://www.artillery.io/docs/guides/integration-guides/github-actions

- Artilley Config/Scenarios references: https://www.artillery.io/docs/guides/guides/test-script-reference

- https://dev.to/brpaz/load-testing-your-applications-with-artillery-4m1p

- AWS references: https://aws.amazon.com/blogs/compute/load-testing-a-web-applications-serverless-backend/

## API Load Testing Reports

- Reports present in `ZIP` file within `Artifacts` section, generated by Github Actions workflow:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/load-test-report.png" width="100%" />

- Files included within report:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/load-test-report-files.png" width="50%" />

## API Load Testing Conditions

Load testing results for `hello` endpoint -> `response time` for 95% of requests (`p95` parameter) is close to `40ms`:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/load-test-response-time-hello-endpoint.png" width="100%" />

- It's possible to configure Artillery to return a non-zero exit code if the test run doesn't comply with **specified conditions based on a set of parameters** like error rate, minimum, maximum and percentile based latency or **response time.**

- The following configuration **will ensure that at least 95% of requests are executed below 50ms** (helps to include some buffer for warm up time), otherwise, the command will exit with an error.

```ruby
config:
  ensure:
    p95: 50
```

- This is really useful in a CI environment as you can make the test fail **if it doesn't meet your performance requirements.**

## Testing Lambda Authorizer (AWS Console)

### 1. `Authorization` header with `allow` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/1.png" width="100%" />

### 2. `Authorization` header with `deny` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/2.png" width="100%" />

AWS Reference for `401` errors: https://aws.amazon.com/premiumsupport/knowledge-center/api-gateway-401-error-lambda-authorizer/

## Testing for token-based Lambda authorizers (Postman)

If `Lambda Event Payload` is set as `Token`, then check the `Token Source` value. The `Token Source` value must be used as the `request header` in calls to your API:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/3.png" width="75%" />

### 1. Postman - `Authorization` header with `allow` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/4.png" width="75%" />

### 2. Postman - `Authorization` header with `deny` value

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/5.png" width="75%" />

### 3. Postman - `Authorization` header not included in request

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/6.png" width="75%" />

# CI/CD (Github Actions -> Terraform -> AWS)

- Deployment can be triggered from `GIT commit messages` by including `[deploy]`.

- Deployment can be triggered `manually` using Terraform CLI within `terraform` folder.

- **Pre Deployment** `linting` and `unit_tests` steps triggered through Github Actions.

- **Post Deployment** `integration_tests` and `load_tests` steps triggered through Github Actions.

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/load-test-report.png" width="100%" />

- Github Actions workflow can be customized here:

```ruby
# .github/workflows/ci_cd.yml

name: "CI/CD Pipeline"

on:
  push:
    paths:
      - "terraform/**"
      - ".github/workflows/**"
    branches:
      - main
  pull_request:
...
```

# Observability, Error Tracking & Cost Monitoring

## Observability

End-to-end observability for serverless: https://dashbird.io/serverless-observability/

## Error Tracking

Error tracking across all serverless services:

- https://dashbird.io/failure-detection/
- https://dashbird.io/aws-lambda-monitoring/

## Cost Monitoring

AWS Lambda Calculator: https://dashbird.io/lambda-cost-calculator/

Optimizing AWS Lambda functions: https://aws.amazon.com/blogs/compute/optimizing-your-aws-lambda-costs-part-1/

## Tagging Best Practices

AWS tags are `key-value` labels you can assign to AWS `resources` that give extra information about them.

Reference: https://engineering.deptagency.com/best-practices-for-terraform-aws-tags

### Searching Resources by `Tag`

https://docs.aws.amazon.com/tag-editor/latest/userguide/find-resources-to-tag.html

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/search-resources-by-tag.png" width="100%" />

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/search-resources-by-tag-results.png" width="100%" />

# REST APIs vs HTTP APIs

- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-routes.html

- REST APIs and HTTP APIs are both RESTful API products.

- REST APIs support more features than HTTP APIs, while HTTP APIs are designed with minimal features so that they can be offered at a lower price.

- Choose REST APIs if you need features such as API keys, per-client throttling, request validation, AWS WAF integration, or private API endpoints.

- Choose HTTP APIs if you don't need the features included with REST APIs.

# API Development Lifecycle

## Configuration steps

1. Clone repository.
2. Validate Terraform <-> Github Actions <-> AWS integration: https://developer.hashicorp.com/terraform/tutorials/automation/github-actions
3. Adjuste `0-providers.tf` file to your own Terraform workspace specifications.

## Adding a new endpoint (same applies for existing endpoints)

1. Create a new branch from `main`.
2. Create a new `NodeJS` function folder. Run `npm init` & `npm install <module>` as you need.
3. Create a new `Lambda function` through `Terraform`.
4. Create a new `Terraform Integration` for said Lambda function.
5. Create `unit`, `integration`, `load_test` tests for said Lambda function.
6. AWS Lambda functions can be tested locally using `aws invoke` command (https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html).
7. Apply `linting` best practices to new function file.
8. Add `unit`, `integration`, `load_test` steps into Github Actions (`ci_cd.yml`) following the same pattern as other lambda functions.
9. Commit changes in your `feature branch` and create a `New Pull Request`.
10. **Pre Deployment** `Github Actions` workflow will be triggered in your new branch:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/pre-deployment-steps.png" width="100%" />

11. Validate `workflow run` results.
12. Once everything is validated by yourself and/or colleagues, push a new commit (it could be an empty one) with the word `[deploy]`.
13. This will trigger **pre deployment** and **post deployment** steps within the **entire github actions workflow**:

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/pre-and-post-deployment-steps.png" width="100%" />

14. Once everything is validated by yourself and/or colleagues, you can merge your branch into `main`.

15. Once Github Actions workflow is successfully completed, a valuable addition is sending a **notification** with workflow results into **Slack channel/s**:

```ruby
# .github/workflows/ci_cd.yml

...

send-notification:
  runs-on: [ubuntu-latest]
  timeout-minutes: 7200
  needs: [linting, unit_tests, deployment, integration_tests, load_tests]
  if: ${{ always() }}
  steps:
    - name: Send Slack Notification
      uses: rtCamp/action-slack-notify@v2
      if: always()
      env:
        SLACK_CHANNEL: devops-sample-slack-channel
        SLACK_COLOR: ${{ job.status }}
        SLACK_ICON: https://avatars.githubusercontent.com/u/54465427?v=4
        SLACK_MESSAGE: |
          "Lambda Functions (Linting): ${{ needs.linting.outputs.status || 'Not Performed' }}" \
          "Lambda Functions (Unit Testing): ${{ needs.unit_tests.outputs.status || 'Not Performed' }}" \
          "API Deployment: ${{ needs.deployment.outputs.status }}" \
          "API Tests (Integration): ${{ needs.integration_tests.outputs.status || 'Not Performed' }}" \
          "API Tests (Load): ${{ needs.load_tests.outputs.status || 'Not Performed' }}"
        SLACK_TITLE: CI/CD Pipeline Results
        SLACK_USERNAME: Github Actions Bot
        SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
```

**CI/CD Slack Notification example:**

<img src="https://github.com/juanroldan1989/terraform-with-rest-api-gateway-and-lambda-functions/raw/main/screenshots/slack-notification-from-pipeline.png" width="100%" />

# Further improvements

## Terraform modules

REST API Gateway `integration` files for all Lambda Functions could be refactored within a `lambda` module to concentrate shared infrastructure code.

## Deployment with extra conditions

- In the same way `deployment` can be triggered via GIT Commit messages, we can apply a similar behavior to each `linting`, `unit_tests`, `integration_tests` and/or `load_tests` steps within Github Actions workflows:

```ruby
  linting:
    name: "Lambda Functions (Linting)"
    if: "contains(github.event.head_commit.message, '[linting]')"
```

```ruby
  linting:
    name: "Lambda Functions (Unit Testing)"
    if: "contains(github.event.head_commit.message, '[unit_tests]')"
```

```ruby
  integration_tests:
    name: "API Testing"
    if: "contains(github.event.head_commit.message, '[integration_tests]')"
```

```ruby
  load_tests:
    name: "API Load Testing"
    if: "contains(github.event.head_commit.message, '[load_tests]')"
```

- This will provide developers with more **granular control** over which **types of tests** to run as they see fit. E.g.: if a `hot fix` is applied to `main` branch, it might be **really useful** to just run **specific** set of tests given time is a priority.

- Also, a **default** tests list (e.g.: `linting`, `unit_tests`, `integration_tests` and `load_tests`) could be set to run **every time** a new feature is added to `main` branch.

## Authorizer Lambda Function logic

Once `token` is received within Authorizer Lambda function, there are a couple of ways to validate it:

1. Call out to OAuth provider
2. Decode a JWT token inline
3. Lookup in a self-managed DB
