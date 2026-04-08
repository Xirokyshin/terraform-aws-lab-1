const { DynamoDBClient, DeleteItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const courseId = event.pathParameters ? event.pathParameters.id : "1";
  const params = { TableName: process.env.TABLE_NAME, Key: { "id": { S: courseId } } };
  
  try {
    await client.send(new DeleteItemCommand(params));
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: `Course ${courseId} deleted successfully` })
    };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ message: "Error deleting course" }) };
  }
};