const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Key: { "id": { S: event.id || "1" } }
  };
  try {
    const data = await client.send(new GetItemCommand(params));
    return data.Item;
  } catch (err) {
    console.error(err);
    throw err;
  }
};