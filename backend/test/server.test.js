const assert = require('node:assert/strict');
const http = require('node:http');
const { test } = require('node:test');

const { createApp } = require('../server');

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

test('movie search calls TMDB and maps results to Pickle items', async () => {
  let requestUrl;
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async (url) => {
      requestUrl = new URL(url);
      return {
        ok: true,
        json: async () => ({
          results: [
            {
              id: 42,
              title: 'Arrival',
              poster_path: '/arrival.jpg',
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
        providerId: '42',
        posterUrl: 'https://image.tmdb.org/t/p/w500/arrival.jpg',
      },
    ]);
    assert.equal(requestUrl.pathname, '/3/search/movie');
    assert.equal(requestUrl.searchParams.get('api_key'), 'test-key');
    assert.equal(requestUrl.searchParams.get('query'), 'Arrival');
  });
});

test('TV search maps TMDB show names', async () => {
  await withServer({
    apiKey: 'test-key',
    fetchImpl: async (url) => {
      assert.equal(new URL(url).pathname, '/3/search/tv');
      return {
        ok: true,
        json: async () => ({
          results: [{ id: 123, name: 'The Bear', poster_path: null }],
        }),
      };
    },
  }, async (server) => {
    const response = await getJson(server, '/search?type=tv&query=The%20Bear');

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, [
      { title: 'The Bear', providerId: '123', posterUrl: null },
    ]);
  });
});

test('search validates types and reports missing API key', async () => {
  await withServer({ apiKey: '', fetchImpl: async () => assert.fail() }, async (server) => {
    const unsupported = await getJson(server, '/search?type=person&query=Arrival');
    const unconfigured = await getJson(server, '/search?type=movie&query=Arrival');

    assert.equal(unsupported.status, 400);
    assert.equal(unconfigured.status, 503);
    assert.match(unconfigured.body.error, /TMDB_API_KEY/);
  });
});
