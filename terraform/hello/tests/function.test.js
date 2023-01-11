const { handler } = require('../function');

describe('handler - GET requests', () => {
  test('should return default message when no parameters are provided', async () => {
    const defaultMessage = 'Hello, world!';
    const event = {};
    const response = await handler(event);

    expect(response.body).toEqual(`{\"message\":\"${defaultMessage}\"}`);
    expect(response.statusCode).toEqual(200);
  });

  test('should return custom message when NAME parameter is provided', async () => {
    const name = 'John';
    const customMessage = `Hello, ${name}!`;
    const event = { 'queryStringParameters' : { 'Name': name } };
    const response = await handler(event);

    expect(response.body).toEqual(`{\"message\":\"${customMessage}\"}`);
    expect(response.statusCode).toEqual(200);
  });
});

describe('handler - POST requests', () => {
  test('should return custom message when NAME attribute is provided', async () => {
    const name = 'Francis';
    const customMessage = `Hello, ${name}!`;
    const event = { "httpMethod" : "POST", 'body' : '{ "name" : "Francis" }' };
    const response = await handler(event);

    expect(response.body).toEqual(`{\"message\":\"${customMessage}\"}`);
    expect(response.statusCode).toEqual(200);
  })
});
