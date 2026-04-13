const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : event;
  } catch (e) {
    console.error("Invalid JSON:", e);
    return { 
      statusCode: 400, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "Invalid JSON format" }) 
    };
  }
  
  // Генеруємо ID
  const generatedId = body.title ? body.title.toLowerCase().replace(/[^a-z0-9]+/g, '-') : Date.now().toString();
  const finalId = body.id || generatedId;
  
  const itemToSave = {
    "id": { S: finalId },
    "title": { S: body.title || "New Course" },
    "authorId": { S: body.authorId || "author-1" },
    "category": { S: body.category || "General" }
  };
  if (body.watchHref) itemToSave.watchHref = { S: body.watchHref };
  if (body.length) itemToSave.length = { S: body.length };

  const params = { TableName: process.env.TABLE_NAME, Item: itemToSave };
  
  try {
    await client.send(new PutItemCommand(params));
    
    // ВАЖЛИВО: Створюємо правильну відповідь ДЛЯ ФРОНТЕНДУ (з нашим новим ID)
    const responseBody = {
        id: finalId,
        title: body.title || "New Course",
        authorId: body.authorId || "author-1",
        category: body.category || "General",
        watchHref: body.watchHref,
        length: body.length
    };
    
    return {
      statusCode: 201, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(responseBody) // Повертаємо об'єкт з ID
    };
  } catch (err) {
    console.error("Error saving course:", err);
    return { 
      statusCode: 500, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "Error saving course", details: err.message }) 
    };
  }
};