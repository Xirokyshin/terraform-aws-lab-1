const https = require('https');

exports.handler = async (event) => {
    const snsMessage = event.Records[0].Sns.Message;
    const webhookUrl = "https://hooks.slack.com/services/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"; 

    const payload = JSON.stringify({ text: `🚨 *AWS Alert!* \n ${snsMessage}` });

    const options = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    };

    return new Promise((resolve) => {
        const req = https.request(webhookUrl, options, (res) => resolve());
        req.write(payload);
        req.end();
    });
};