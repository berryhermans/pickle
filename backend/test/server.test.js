const assert = require('node:assert/strict');
const http = require('node:http');
const { test } = require('node:test');

const { createApp } = require('../src/app');

async function withServer(options, run) {
  const server = createApp(options).listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  try {
    await run(server);
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  }
}

function getJson(server, pathname) {
  const { port } = server.address();
  return new Promise((resolve, reject) => {
    http.get({ host: '127.0.0.1', port, path: pathname }, (response) => {
      let body = '';
      response.setEncoding('utf8');
      response.on('data', (chunk) => { body += chunk; });
      response.on('end', () => {
        resolve({ status: response.statusCode, body: JSON.parse(body) });
      });
    }).on('error', reject);
  });
}

test('movie search calls OMDb and maps results to Pickle items', async () => {
  let requestUrl;
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async (url) => {
      requestUrl = new URL(url);
      return {
        ok: true,
        json: async () => ({
          Search: [
            {
              imdbID: 'tt2543164',
              Title: 'Arrival',
              Poster: 'https://example.com/arrival.jpg',
            },
          ],
        }),
      };
    },
  }, async (server) => {
    const response = await getJson(server, '/search?type=movie&query=Arrival');

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, [
      {
        title: 'Arrival',
        providerId: 'tt2543164',
        posterUrl: 'https://example.com/arrival.jpg',
      },
    ]);
    assert.equal(requestUrl.href.split('?')[0], 'https://www.omdbapi.com/');
    assert.equal(requestUrl.searchParams.get('apikey'), 'test-key');
    assert.equal(requestUrl.searchParams.get('s'), 'Arrival');
    assert.equal(requestUrl.searchParams.get('type'), 'movie');
  });
});

test('TV search uses the OMDb series type and maps show names', async () => {
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async (url) => {
      const requestUrl = new URL(url);
      assert.equal(requestUrl.origin + requestUrl.pathname, 'https://www.omdbapi.com/');
      assert.equal(requestUrl.searchParams.get('type'), 'series');
      return {
        ok: true,
        json: async () => ({
          Search: [{ imdbID: 'tt14452776', Title: 'The Bear', Poster: 'N/A' }],
        }),
      };
    },
  }, async (server) => {
    const response = await getJson(server, '/search?type=tv&query=The%20Bear');

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, [
      { title: 'The Bear', providerId: 'tt14452776', posterUrl: null },
    ]);
  });
});

test('search validates types and reports missing OMDb API key', async () => {
  await withServer({ apiKey: '', fetchImpl: async () => assert.fail() }, async (server) => {
    const unsupported = await getJson(server, '/search?type=person&query=Arrival');
    const unconfigured = await getJson(server, '/search?type=movie&query=Arrival');

    assert.equal(unsupported.status, 400);
    assert.equal(unconfigured.status, 503);
    assert.match(unconfigured.body.error, /OMDB_API_KEY/);
  });
});

test('search returns an empty list when OMDb has no matches', async () => {
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({ Response: 'False', Error: 'Movie not found!' }),
    }),
  }, async (server) => {
    const response = await getJson(server, '/search?type=movie&query=not-a-title');

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, []);
  });
});

test('health and API root endpoints remain available', async () => {
  await withServer({}, async (server) => {
    const health = await getJson(server, '/health');
    const root = await getJson(server, '/');

    assert.deepEqual(health, { status: 200, body: { status: 'ok' } });
    assert.equal(root.status, 200);
    assert.deepEqual(root.body.endpoints, ['/search', '/health']);
  });
});

test('OMDb failures use the centralized error response', async () => {
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({ Response: 'False', Error: 'Invalid API key!' }),
    }),
  }, async (server) => {
    const response = await getJson(server, '/search?type=movie&query=Arrival');

    assert.equal(response.status, 502);
    assert.deepEqual(response.body, { error: 'OMDb search failed' });
  });
});
