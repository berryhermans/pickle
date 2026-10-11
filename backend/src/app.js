const express = require('express');
const cors = require('cors');

const { getConfig } = require('./config');
const { createRouter } = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { createOmdbService } = require('./services/omdbService');

function createApp({ apiKey = getConfig().omdbApiKey, fetchImpl = fetch } = {}) {
  const app = express();
  const omdbService = createOmdbService({ apiKey, fetchImpl });

  app.use(cors());
  app.use(express.json());
  app.use(createRouter({ omdbService }));
  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
