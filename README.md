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
