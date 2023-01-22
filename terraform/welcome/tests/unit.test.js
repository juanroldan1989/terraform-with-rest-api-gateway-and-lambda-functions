const { handler } = require('../function');

describe('handler - GET requests', () => {
  test('should return default message ', async () => {
    const defaultMessage = 'Welcome :)';
    const event = {};
    const response = await handler(event);

    expect(response.body).toEqual(`{\"message\":\"${defaultMessage}\"}`);
    expect(response.statusCode).toEqual(200);
  });
});
