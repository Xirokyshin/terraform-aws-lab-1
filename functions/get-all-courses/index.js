const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  const params = { TableName: process.env.TABLE_NAME };
  try {
    const data = await client.send(new ScanCommand(params));
    return data.Items.map(item => ({
      id: item.id ? item.id.S : null,
      title: item.title ? item.title.S : null,
      authorId: item.authorId ? item.authorId.S : null,
      category: item.category ? item.category.S : null
    }));
  } catch (err) {
    console.error(err);
    throw err;
  }
};