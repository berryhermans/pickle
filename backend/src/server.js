const http = require('node:http');

const { createApp } = require('./app');

const PORT = Number(process.env.PORT) || 8080;
const server = http.createServer(createApp());

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Pickle API running on http://0.0.0.0:${PORT}`);
});

function shutdown(signal) {
  console.log(`${signal} received; closing the HTTP server`);
  server.close((error) => {
    if (error) {
      console.error('Failed to close the HTTP server cleanly:', error);
      process.exitCode = 1;
    }
  });
}

process.once('SIGTERM', () => shutdown('SIGTERM'));
process.once('SIGINT', () => shutdown('SIGINT'));
