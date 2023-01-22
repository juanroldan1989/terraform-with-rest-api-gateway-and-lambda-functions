const { handler } = require('../function');
const policy = {
  "context": {
      "booleanKey": true,
      "numberKey": 123,
      "stringKey": "stringval",
    },
  "principalId": "user|a1b2c3d4"
};
const context = {};
const callback = jest.fn().mockImplementation((policy) => {
  if (policy) { 'message' };
});

describe('handler - GET requests', () => {
  test('should return `Allow` policy when token provided is `allow`', async () => {
    const event = { 'authorizationToken' : 'allow' };

    await handler(event, context, callback);

    expect(callback).toHaveBeenCalledWith(null, policy);
  });

  test('should return `Deny` policy when token provided is `deny`', async () => {
    const event = { 'authorizationToken' : 'deny' };

    await handler(event, context, callback);

    expect(callback).toHaveBeenCalledWith(null, policy);
  });

  test('should return `Unauthorized` policy when token provided is `unauthorized`', async () => {
    const event = { 'authorizationToken' : 'unauthorized' };

    await handler(event, context, callback);

    expect(callback).toHaveBeenCalledWith(null, policy);
  });

  test('should return `Error: Invalid token` when token provided is none of above', async () => {
    const event = { 'authorizationToken' : 'none' };

    await handler(event, context, callback);

    expect(callback).toHaveBeenCalledWith('Error: Invalid token');
  });
});
