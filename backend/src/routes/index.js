const express = require('express');

const { createHealthRouter } = require('../endpoints/health');
const { createSearchRouter } = require('../endpoints/search');

function createRouter({ omdbService }) {
  const router = express.Router();

  router.get('/', (req, res) => {
    res.json({
      name: 'Pickle API',
      status: 'ok',
      endpoints: ['/search', '/health'],
    });
  });
  router.use('/health', createHealthRouter());
  router.use('/search', createSearchRouter({ omdbService }));

  return router;
}

module.exports = { createRouter };
