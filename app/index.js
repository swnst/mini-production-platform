const express = require('express');
const client = require('prom-client');

const app = express();
const port = 3000;

// collect default metrics
client.collectDefaultMetrics();

app.get('/', (req, res) => {
  res.json({ status: "ok", service: "mini-platform-app" });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
