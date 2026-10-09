class HttpError extends Error {
  constructor(status, publicMessage, options = {}) {
    super(publicMessage, options);
    this.name = 'HttpError';
    this.status = status;
    this.publicMessage = publicMessage;
  }
}

module.exports = { HttpError };
