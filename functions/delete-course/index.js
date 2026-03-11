const { DynamoDBClient, DeleteItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Key: { "id": { S: event.id || "1" } }
  };
  try {
    await client.send(new DeleteItemCommand(params));
    return { message: "Course deleted successfully" };
  } catch (err) {
    console.error(err);
    throw err;
  }
};