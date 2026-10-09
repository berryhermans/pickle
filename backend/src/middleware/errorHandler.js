function errorHandler(error, req, res, next) {
  if (res.headersSent) return next(error);

  const status = Number.isInteger(error.status) ? error.status : 500;
  if (status >= 500 && (!error.publicMessage || error.cause)) {
    console.error(error.cause || error);
  }

  const message = status >= 500 && status < 600
    ? error.publicMessage || 'Internal server error'
    : error.message;

  return res.status(status).json({ error: message });
}

module.exports = { errorHandler };
