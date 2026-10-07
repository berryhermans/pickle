const path = require('node:path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '.env') });

const PORT = Number(process.env.PORT) || 8080;
const TMDB_API_BASE_URL = 'https://api.themoviedb.org/3';
const TMDB_IMAGE_BASE_URL = 'https://image.tmdb.org/t/p/w500';

function createApp({ apiKey = process.env.TMDB_API_KEY, fetchImpl = fetch } = {}) {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get('/', (req, res) => {
    res.json({
      name: 'Pickle API',
      status: 'ok',
      endpoints: ['/search', '/health'],
    });
  });

  app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
  });

  app.get('/search', async (req, res) => {
    const type = typeof req.query.type === 'string'
      ? req.query.type.toLowerCase()
      : 'movie';
    const query = typeof req.query.query === 'string'
      ? req.query.query.trim()
      : '';

    if (!['movie', 'tv'].includes(type)) {
      return res.status(400).json({ error: 'type must be movie or tv' });
    }
    if (!query) {
      return res.json([]);
    }
    if (!apiKey) {
      return res.status(503).json({ error: 'TMDB_API_KEY is not configured' });
    }

    const url = new URL(`${TMDB_API_BASE_URL}/search/${type}`);
    url.searchParams.set('api_key', apiKey);
    url.searchParams.set('query', query);

    try {
      const response = await fetchImpl(url, {
        signal: AbortSignal.timeout(8000),
      });
      if (!response.ok) {
        console.error(`TMDB search failed with status ${response.status}`);
        return res.status(502).json({ error: 'TMDB search failed' });
      }

      const payload = await response.json();
      const results = Array.isArray(payload.results)
        ? payload.results.map((item) => mapResult(item, type)).filter(Boolean)
        : [];
      return res.json(results);
    } catch (error) {
      const timedOut = error.name === 'TimeoutError' || error.name === 'AbortError';
      console.error('TMDB search request failed:', error.message);
      return res
        .status(timedOut ? 504 : 502)
        .json({ error: timedOut ? 'TMDB search timed out' : 'TMDB search failed' });
    }
  });

  return app;
}

function mapResult(item, type) {
  const title = type === 'movie' ? item.title : item.name;
  if (!title || item.id == null) return null;

  return {
    title,
    providerId: String(item.id),
    posterUrl: item.poster_path
      ? `${TMDB_IMAGE_BASE_URL}${item.poster_path}`
      : null,
  };
}

const app = createApp();

if (require.main === module) {
  const server = app.listen(PORT, '0.0.0.0', () => {
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
}

module.exports = { app, createApp };
