// From AWS Offical Docs:
// https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html

// A simple token-based authorizer example to demonstrate how to use an authorization token
// to allow or deny a request. In this example, the caller named 'user' is allowed to invoke
// a request if the client-supplied token value is 'allow'. The caller is not allowed to invoke
// the request if the token value is 'deny'. If the token value is 'unauthorized' or an empty
// string, the authorizer function returns an HTTP 401 status code. For any other token value,
// the authorizer returns an HTTP 500 status code.
// Note that token values are case-sensitive.

exports.handler = async (event, context, callback) => {
  console.log('Event: ', event);
  let token = event.authorizationToken;
  switch (token) {
      case 'allow':
          callback(null, generatePolicy('user', 'Allow', event.methodArn));
          break;
      case 'deny':
          callback(null, generatePolicy('user', 'Deny', event.methodArn));
          break;
      case 'unauthorized':
          callback("Unauthorized");         // Return a 401 Unauthorized response
          break;
      default:
          callback("Error: Invalid token"); // Return a 500 Invalid token response
  }
};

// Help function to generate an IAM policy
let generatePolicy = function(principalId, effect, resource) {
  let authResponse = {};

  authResponse.principalId = principalId;
  if (effect && resource) {
      let policyDocument = {};
      policyDocument.Version = '2012-10-17';
      policyDocument.Statement = [];
      let statementOne = {};
      statementOne.Action = 'execute-api:Invoke';
      statementOne.Effect = effect;
      statementOne.Resource = resource;
      policyDocument.Statement[0] = statementOne;
      authResponse.policyDocument = policyDocument;
  }

  // Optional output with custom properties of the String, Number or Boolean type.
  authResponse.context = {
      "stringKey": "stringval",
      "numberKey": 123,
      "booleanKey": true
  };
  return authResponse;
}
