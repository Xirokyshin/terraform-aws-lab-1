const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      "id": { S: event.id || Math.random().toString() },
      "title": { S: event.title || "New Course" },
      "authorId": { S: event.authorId || "author-1" },
      "category": { S: event.category || "General" }
    }
  };
  try {
    await client.send(new PutItemCommand(params));
    return { message: "Course saved successfully" };
  } catch (err) {
    console.error(err);
    throw err;
  }
};