# REST API Gateway

- Routes integration with Lambda Functions
- Usage Plans
- Rate Limits
- Throttle Configuration
- Deployment through Github Actions -> Terraform -> AWS

## REST APIs vs HTTP APIs

- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-routes.html

- REST APIs and HTTP APIs are both RESTful API products.

- REST APIs support more features than HTTP APIs, while HTTP APIs are designed with minimal features so that they can be offered at a lower price.

- Choose REST APIs if you need features such as API keys, per-client throttling, request validation, AWS WAF integration, or private API endpoints.

- Choose HTTP APIs if you don't need the features included with REST APIs.

## REST API implementation through Terraform

- With a REST API we can apply **Usage Plans, Rate Limits and Throttle Configuration.**

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api

```
Resource: aws_apigatewayv2_api
Manages an Amazon API Gateway Version 2 API.
```

Note:

- Amazon API Gateway Version 2 resources are used for creating and deploying **WebSocket and HTTP APIs.**

- To create and deploy **REST APIs**, use Amazon **API Gateway Version 1** resources.
