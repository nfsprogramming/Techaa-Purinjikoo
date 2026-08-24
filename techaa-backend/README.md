# Techaa Purinjikoo — Go Backend V1

A lightweight, high-performance Go REST API designed for **low memory usage** and optimized for **Render Free Tier Web Service** deployment with **PostgreSQL**.

---

## 🌟 Features

- **Standard Library First**: Built with `net/http`, `log/slog`, `database/sql`, and `lib/pq`.
- **Ultra-Low Memory Footprint**: Uses < 15MB RAM at runtime.
- **Server-Authoritative XP Ledger**: Duplicate reward prevention via database uniqueness constraints and transaction logs.
- **Deterministic Streaks & Level Engine**: Server-side UTC streak evaluation matching `gamification.js`.
- **Verifiable Certificate System**: Server validates course completion before issuing unique codes (`TP-<COURSE>-<UNIQUE_ID>`).
- **Monotonic Offline Sync**: Merges offline topics and bookmarks seamlessly upon internet connection or guest-to-auth migration.
- **Render Ready**: Includes `render.yaml` blueprint with health probes and dynamic `PORT` binding.

---

## 🚀 Getting Started

### Requirements
- Go `1.22+` (or `1.26+`)
- PostgreSQL `14+`

### 1. Environment Configuration
Copy the example environment file:
```bash
cp .env.example .env
```

### 2. Run Database Migrations
Migrations run automatically on application startup from `internal/database/migrations/000001_init_schema.up.sql`.

### 3. Start the Server
```bash
go run cmd/server/main.go
```

### 4. Run Tests
```bash
go test -v ./...
go vet ./...
```

---

## 📡 API Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Service health probe | No |
| `GET` | `/health/ready` | Database readiness probe | No |
| `GET` | `/api/v1/auth/me` | Current user & profile | Yes (Bearer Token) |
| `GET` | `/api/v1/profile` | Get profile details | Yes |
| `PATCH` | `/api/v1/profile` | Update profile | Yes |
| `GET` | `/api/v1/progress` | Progress overview | Yes |
| `POST` | `/api/v1/progress/topics/{id}/complete` | Mark topic complete & award XP | Yes |
| `GET` | `/api/v1/xp/summary` | XP ledger & level progress | Yes |
| `GET` | `/api/v1/badges` | Unlocked badges list | Yes |
| `GET` | `/api/v1/streak` | Server streak calculator | Yes |
| `GET` | `/api/v1/courses/progress` | All 3 courses progress | Yes |
| `POST` | `/api/v1/courses/{id}/claim-certificate` | Issue verified certificate | Yes |
| `GET` | `/api/v1/certificates/verify/{id}` | Public certificate verification | No |
| `POST` | `/api/v1/sync` | Offline progress batch sync | Yes |
| `POST` | `/api/v1/reports` | Content typo / feedback report | No / Optional |
