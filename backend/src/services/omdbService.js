const OMDB_API_URL = 'https://www.omdbapi.com/';

const NOT_FOUND_ERRORS = new Set(['Movie not found!', 'Series not found!']);
const { HttpError } = require('../errors/httpError');

function createOmdbService({ apiKey, fetchImpl = fetch }) {
  async function search({ type, query }) {
    if (!apiKey) {
      throw new HttpError(503, 'OMDB_API_KEY is not configured');
    }

    const url = new URL(OMDB_API_URL);
    url.searchParams.set('apikey', apiKey);
    url.searchParams.set('s', query);
    url.searchParams.set('type', type === 'tv' ? 'series' : 'movie');

    try {
      const response = await fetchImpl(url, {
        signal: AbortSignal.timeout(8000),
      });
      if (!response.ok) {
        throw new Error(`OMDb returned HTTP ${response.status}`);
      }

      const payload = await response.json();
      if (payload.Response === 'False') {
        if (NOT_FOUND_ERRORS.has(payload.Error)) return [];
        throw new Error(`OMDb search failed: ${payload.Error || 'unknown error'}`);
      }
      if (!Array.isArray(payload.Search)) {
        throw new Error('OMDb search response did not include results');
      }

      return payload.Search.map(mapResult).filter(Boolean);
    } catch (error) {
      if (error instanceof HttpError) throw error;

      const timedOut = error.name === 'TimeoutError' || error.name === 'AbortError';
      throw new HttpError(
        timedOut ? 504 : 502,
        timedOut ? 'OMDb search timed out' : 'OMDb search failed',
        { cause: error },
      );
    }
  }

  return { search };
}

function mapResult(item) {
  if (!item || !item.Title || !item.imdbID) return null;

  return {
    title: item.Title,
    providerId: String(item.imdbID),
    posterUrl: item.Poster && item.Poster !== 'N/A' ? item.Poster : null,
  };
}

module.exports = { createOmdbService };
