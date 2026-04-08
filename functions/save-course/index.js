const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  // Розпарсимо тіло запиту від API Gateway
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : event;
  } catch (e) {
    return { statusCode: 400, body: JSON.stringify({ message: "Invalid JSON format" }) };
  }
  
  const itemToSave = {
    "id": { S: body.id || Date.now().toString() }, // Генеруємо ID, якщо не передали
    "title": { S: body.title || "New Course" },
    "authorId": { S: body.authorId || "author-1" },
    "category": { S: body.category || "General" }
  };
  if (body.watchHref) itemToSave.watchHref = { S: body.watchHref };
  if (body.length) itemToSave.length = { S: body.length };

  const params = { TableName: process.env.TABLE_NAME, Item: itemToSave };
  try {
    await client.send(new PutItemCommand(params));
    return {
      statusCode: 201, // 201 означає "Створено"
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(body)
    };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ message: "Error saving course" }) };
  }
};