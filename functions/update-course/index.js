const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const courseId = event.pathParameters ? event.pathParameters.id : "1";
  
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : event;
  } catch (e) {
    console.error("Invalid JSON:", e);
    return { 
      statusCode: 400, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }, // ДОДАНО CORS
      body: JSON.stringify({ message: "Invalid JSON format" }) 
    };
  }
  
  // Беремо ID з URL (courseId), а не з тіла, щоб уникнути конфліктів
  const itemToSave = {
    "id": { S: courseId }, 
    "title": { S: body.title || "Updated Course" },
    "authorId": { S: body.authorId || "author-1" },
    "category": { S: body.category || "Updated Category" }
  };
  if (body.watchHref) itemToSave.watchHref = { S: body.watchHref };
  if (body.length) itemToSave.length = { S: body.length };

  const params = { TableName: process.env.TABLE_NAME, Item: itemToSave };
  try {
    await client.send(new PutItemCommand(params));
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      // Повертаємо оновлений об'єкт
      body: JSON.stringify({ id: courseId, ...body }) 
    };
  } catch (err) {
    console.error("Error updating course:", err);
    return { 
      statusCode: 500, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }, // ДОДАНО CORS
      body: JSON.stringify({ message: "Error updating course", details: err.message }) 
    };
  }
};