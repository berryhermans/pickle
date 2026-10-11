const express = require('express');

const { asyncHandler } = require('../middleware/asyncHandler');
const { HttpError } = require('../errors/httpError');

function validateSearchQuery(req, res, next) {
  const type = typeof req.query.type === 'string'
    ? req.query.type.toLowerCase()
    : 'movie';
  const query = typeof req.query.query === 'string'
    ? req.query.query.trim()
    : '';

  if (!['movie', 'tv'].includes(type)) {
    return next(new HttpError(400, 'type must be movie or tv'));
  }

  res.locals.search = { type, query };
  return next();
}

function createSearchRouter({ omdbService }) {
  const router = express.Router();

  router.get(
    '/',
    validateSearchQuery,
    asyncHandler(async (req, res) => {
      const { type, query } = res.locals.search;
      if (!query) return res.json([]);

      const results = await omdbService.search({ type, query });
      return res.json(results);
    }),
  );

  return router;
}

module.exports = { createSearchRouter, validateSearchQuery };
