const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = { TableName: process.env.TABLE_NAME };
  try {
    const data = await client.send(new ScanCommand(params));
    
    // 1. Формуємо масив курсів З УСІМА ПОЛЯМИ
    const courses = data.Items.map(item => ({
      id: item.id ? item.id.S : null,
      title: item.title ? item.title.S : null,
      authorId: item.authorId ? item.authorId.S : null,
      category: item.category ? item.category.S : null,
      watchHref: item.watchHref ? item.watchHref.S : "", // ДОДАНО
      length: item.length ? item.length.S : ""         // ДОДАНО
    }));

    // 2. ПАКУЄМО ДАНІ В КОНВЕРТ ДЛЯ API GATEWAY
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" 
      },
      body: JSON.stringify(courses) 
    };

  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // ДОДАНО CORS ДЛЯ ПОМИЛОК
      },
      body: JSON.stringify({ message: "Failed to fetch courses" })
    };
  }
};