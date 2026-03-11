const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      "id": { S: event.id || "1" },
      "title": { S: event.title || "Updated Course" },
      "authorId": { S: event.authorId || "author-1" },
      "category": { S: event.category || "Updated Category" }
    }
  };
  try {
    await client.send(new PutItemCommand(params));
    return { message: "Course updated successfully" };
  } catch (err) {
    console.error(err);
    throw err;
  }
};