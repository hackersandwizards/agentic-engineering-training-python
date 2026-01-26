# CRM Training Application (FastAPI + React)

A training CRM application built with FastAPI, React, and SQLite.

## Tech Stack

- **Backend**: FastAPI (Python 3.11+)
- **Database**: SQLite
- **Authentication**: JWT tokens
- **Frontend**: React + TypeScript
- **UI**: Chakra UI v3
- **Build**: Vite

## Features

- User authentication (login/signup)
- Contact management (CRUD)
- User administration (superuser only)
- Profile settings
- REST API with OpenAPI docs

## Quick Start

### Requirements

- Python 3.11+
- Node.js 18+
- uv (Python package manager)

### Setup

```bash
./scripts/setup-local.sh
```

Then in separate terminals:

```bash
# Terminal 1: Backend
cd backend && uv run uvicorn app.main:app --reload

# Terminal 2: Frontend
cd frontend && npm run dev
```

Open http://localhost:5173

## Default Users

| Email | Password | Role |
|-------|----------|------|
| dev@example.com | DevPassword | Superuser |
| alice@example.com | AlicePassword123 | User |
| bob@example.com | BobPassword123 | User |

## Project Structure

```
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── deps.py          # Dependencies (get_db, get_current_user)
│   │   │   ├── main.py          # API router
│   │   │   └── routes/
│   │   │       ├── login.py     # Auth endpoints
│   │   │       ├── users.py     # User endpoints
│   │   │       └── contacts.py  # Contact endpoints
│   │   ├── core/
│   │   │   ├── config.py        # Settings
│   │   │   ├── db.py            # Database setup
│   │   │   └── security.py      # JWT + password hashing
│   │   ├── main.py              # FastAPI app
│   │   ├── models.py            # SQLModel models
│   │   └── crud.py              # Database operations
│   └── pyproject.toml
├── frontend/
│   ├── src/
│   │   ├── components/          # React components
│   │   ├── routes/              # Page components
│   │   ├── hooks/               # Custom hooks + API client
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   └── vite.config.ts
├── scripts/
│   └── setup-local.sh
├── .env
└── README.md
```

## REST API

Base URL: `/api/v1`

### Authentication

```bash
# Login (get bearer token)
POST /api/v1/login/access-token
Content-Type: application/x-www-form-urlencoded
username=dev@example.com&password=DevPassword

# Response
{
  "access_token": "...",
  "token_type": "bearer"
}

# Test token validity
POST /api/v1/login/test-token
Authorization: Bearer <token>
```

### Users

```bash
# Get current user
GET /api/v1/users/me
Authorization: Bearer <token>

# Update profile
PATCH /api/v1/users/me
Authorization: Bearer <token>
{
  "email": "new@example.com",
  "full_name": "New Name"
}

# Change password
PATCH /api/v1/users/me/password
Authorization: Bearer <token>
{
  "current_password": "...",
  "new_password": "..."
}

# Signup (public)
POST /api/v1/users/signup
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "User Name"
}

# Admin: List users
GET /api/v1/users
Authorization: Bearer <token>  # requires superuser
```

### Contacts

```bash
# List contacts
GET /api/v1/contacts
Authorization: Bearer <token>

# Create contact
POST /api/v1/contacts
Authorization: Bearer <token>
{
  "organisation": "Company Name",
  "description": "Optional description"
}

# Get contact
GET /api/v1/contacts/{id}
Authorization: Bearer <token>

# Update contact
PUT /api/v1/contacts/{id}
Authorization: Bearer <token>

# Delete contact
DELETE /api/v1/contacts/{id}
Authorization: Bearer <token>
```

### Health Check

```bash
GET /health
# Response: { "status": "healthy" }
```

## Development Commands

### Backend

```bash
cd backend

# Run server with hot reload
uv run uvicorn app.main:app --reload

# Run tests
uv run pytest

# Format code
uv run ruff format .

# Lint
uv run ruff check .
```

### Frontend

```bash
cd frontend

# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Environment Variables

Key variables in `.env`:

```env
# Database
DATABASE_URL=sqlite:///./database.sqlite

# Security
SECRET_KEY=TheKeyForDevModeNoIssueIfShared

# First superuser
FIRST_SUPERUSER=dev@example.com
FIRST_SUPERUSER_PASSWORD=DevPassword
```

## License

This project is for training purposes.
