exports.handler = async (event) => {
  console.log('Event: ', event);

  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'Goodbye!'
    }),
  };

  return response;
};
