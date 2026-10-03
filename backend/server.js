const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;

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

app.get('/search', (req, res) => {
  const type = String(req.query.type || 'movie').toLowerCase();
  const rawQuery = String(req.query.query || '').trim();
  const query = rawQuery.toLowerCase();

  if (!query) {
    return res.json([]);
  }

  const results = buildResults(type, query);
  return res.json(results);
});

function buildResults(type, query) {
  const items = type === 'tv' ? tvShows : movies;

  return items.filter((item) =>
    item.title.toLowerCase().includes(query),
  );
}

const movies = [
  {
    title: 'Arrival',
    providerId: '42',
    posterUrl: 'https://images.example/arrival.jpg',
    durationMinutes: 116,
    genres: ['Sci-Fi', 'Drama'],
  },
  {
    title: 'The Matrix',
    providerId: '603',
    posterUrl: 'https://images.example/matrix.jpg',
    durationMinutes: 136,
    genres: ['Action', 'Sci-Fi'],
  },
  {
    title: 'Dune: Part Two',
    providerId: '693134',
    posterUrl: 'https://images.example/dune.jpg',
    durationMinutes: 166,
    genres: ['Adventure', 'Sci-Fi'],
  },
];

const tvShows = [
  {
    title: 'The Bear',
    providerId: '153312',
    posterUrl: 'https://images.example/bear.jpg',
    durationMinutes: 36,
    genres: ['Comedy', 'Drama'],
  },
  {
    title: 'The Last of Us',
    providerId: '100088',
    posterUrl: 'https://images.example/last-of-us.jpg',
    durationMinutes: 60,
    genres: ['Drama', 'Action'],
  },
  {
    title: 'Severance',
    providerId: '95557',
    posterUrl: 'https://images.example/severance.jpg',
    durationMinutes: 49,
    genres: ['Mystery', 'Sci-Fi'],
  },
];

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Pickle API running on http://0.0.0.0:${PORT}`);
});
