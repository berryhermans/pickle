const path = require('node:path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

function getConfig() {
  return {
    omdbApiKey: process.env.OMDB_API_KEY,
  };
}

module.exports = { getConfig };
