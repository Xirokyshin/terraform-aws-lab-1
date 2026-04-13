const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  // Дістаємо {id} з URL (наприклад: /courses/101)
  const courseId = event.pathParameters ? event.pathParameters.id : event.id;

  if (!courseId) {
     return { 
       statusCode: 400, 
       headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
       body: JSON.stringify({ message: "Missing course ID" }) 
     };
  }

  const params = { TableName: process.env.TABLE_NAME, Key: { "id": { S: courseId } } };
  
  try {
    const data = await client.send(new GetItemCommand(params));
    
    // Якщо курс не знайдено (наприклад, шукаємо "undefined")
    if (!data.Item) {
      return { 
        statusCode: 404, 
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }, // ДОДАНО CORS
        body: JSON.stringify({ message: "Course not found" }) 
      };
    }
    
    const course = {
      id: data.Item.id ? data.Item.id.S : null,
      title: data.Item.title ? data.Item.title.S : null,
      authorId: data.Item.authorId ? data.Item.authorId.S : null,
      category: data.Item.category ? data.Item.category.S : null,
      watchHref: data.Item.watchHref ? data.Item.watchHref.S : "",
      length: data.Item.length ? data.Item.length.S : ""
    };
    
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(course)
    };
    
  } catch (err) {
    console.error("Error fetching course:", err);
    return { 
      statusCode: 500, 
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }, // ДОДАНО CORS
      body: JSON.stringify({ message: "Error fetching course" }) 
    };
  }
};