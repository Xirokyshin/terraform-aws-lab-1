const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = { TableName: process.env.TABLE_NAME };
  try {
    const data = await client.send(new ScanCommand(params));
    
    // 1. Формуємо наш красивий масив курсів
    const courses = data.Items.map(item => ({
      id: item.id ? item.id.S : null,
      title: item.title ? item.title.S : null,
      authorId: item.authorId ? item.authorId.S : null,
      category: item.category ? item.category.S : null
    }));

    // 2. ПАКУЄМО ДАНІ В КОНВЕРТ ДЛЯ API GATEWAY
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // Це знадобиться пізніше для підключення сайту
      },
      body: JSON.stringify(courses) // Обов'язково перетворюємо JSON в текст (рядок)!
    };

  } catch (err) {
    console.error(err);
    // Навіть помилку треба пакувати правильно
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Failed to fetch courses" })
    };
  }
};