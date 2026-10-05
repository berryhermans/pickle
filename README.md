# Pickle

Pickle is a Flutter app for picking between a list of discreet options.

## Project structure

- frontend/: Flutter app and all UI, models, and persistence logic
- backend/: Express Node.js API for media search lookups

## Run the app

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Backend

```bash
cd backend
npm install
npm start
```

The backend exposes the search endpoint at:

```text
http://localhost:8080/search?type=movie&query=arrival
```

## Deploy the backend to Railway

1. Create a Railway project and deploy this GitHub repository as a service.
2. In the service settings, set the root directory to `/backend`.
3. Railway detects the Node.js app from `package.json`, installs its dependencies, and runs `npm start`.
4. Set the service healthcheck path to `/health` and generate a public domain.

Railway provides the `PORT` environment variable automatically. The backend binds to that port and listens on `0.0.0.0`. After deployment, verify `/health` on the generated domain before using `/search`.
