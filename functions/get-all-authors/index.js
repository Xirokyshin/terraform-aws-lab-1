const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: process.env.REGION });

exports.handler = async (event) => {
  try {
    const data = await client.send(new ScanCommand({ TableName: process.env.TABLE_NAME }));
    const authors = data.Items.map(item => ({
      id: item.id ? item.id.S : null,
      firstName: item.firstName ? item.firstName.S : null,
      lastName: item.lastName ? item.lastName.S : null
    }));
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(authors)
    };
  } catch (err) {
    console.error(err);
    return { statusCode: 500, body: JSON.stringify({ message: "Error fetching authors" }) };
  }
};