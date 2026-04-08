const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  // Дістаємо {id} з URL (наприклад: /courses/101)
  const courseId = event.pathParameters ? event.pathParameters.id : "1";
  const params = { TableName: process.env.TABLE_NAME, Key: { "id": { S: courseId } } };
  
  try {
    const data = await client.send(new GetItemCommand(params));
    if (!data.Item) {
      return { statusCode: 404, body: JSON.stringify({ message: "Course not found" }) };
    }
    const course = {
      id: data.Item.id ? data.Item.id.S : null,
      title: data.Item.title ? data.Item.title.S : null,
      authorId: data.Item.authorId ? data.Item.authorId.S : null,
      category: data.Item.category ? data.Item.category.S : null,
      watchHref: data.Item.watchHref ? data.Item.watchHref.S : null,
      length: data.Item.length ? data.Item.length.S : null
    };
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(course)
    };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ message: "Error fetching course" }) };
  }
};