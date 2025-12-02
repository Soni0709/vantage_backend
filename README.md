# Vantage Finance Tracker (Backend)

Rails REST API powering the Vantage Finance Tracker frontend.  
Handles authentication, transactions, recurring transactions, and savings goals.

**Frontend repo:** https://github.com/Soni0709/vantage_frontend

---

## ✨ Features
- JWT-based authentication (login, register, refresh)
- Transactions CRUD + summary + bulk delete
- Recurring transactions endpoints (processing/upcoming support)
- Savings goals CRUD + add-amount + summary
- PostgreSQL persistence
- Docker-ready setup

---

## 🧰 Tech Stack
- Ruby on Rails (API mode)
- PostgreSQL
- JWT Auth
- Docker

---

## 📦 API Endpoints

### Auth
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout` (if enabled)

### Transactions
- `GET    /api/v1/transactions`
- `GET    /api/v1/transactions/:id`
- `POST   /api/v1/transactions`
- `PUT    /api/v1/transactions/:id`
- `DELETE /api/v1/transactions/:id`
- `GET    /api/v1/transactions/summary`
- `POST   /api/v1/transactions/bulk_delete`

### Recurring Transactions (WIP / Partial)
- `GET    /api/v1/recurring_transactions`
- `POST   /api/v1/recurring_transactions`
- `PUT    /api/v1/recurring_transactions/:id`
- `DELETE /api/v1/recurring_transactions/:id`
- `PATCH  /api/v1/recurring_transactions/:id/toggle`
- `POST   /api/v1/recurring_transactions/process`
- `GET    /api/v1/recurring_transactions/upcoming`

### Savings Goals
- `GET    /api/v1/savings_goals`
- `GET    /api/v1/savings_goals/:id`
- `POST   /api/v1/savings_goals`
- `PUT    /api/v1/savings_goals/:id`
- `DELETE /api/v1/savings_goals/:id`
- `PATCH  /api/v1/savings_goals/:id/add_amount`
- `GET    /api/v1/savings_goals/summary`

---

## 🗃️ Database Schema (Summary)

### transactions
- `id (uuid, PK)`
- `user_id (uuid, FK)`
- `type, amount, description, category`
- `transaction_date`
- `metadata (jsonb)`
- timestamps

### recurring_transactions
- `id (uuid, PK)`
- `user_id (uuid, FK)`
- `type, amount, description, category`
- `frequency`
- `start_date, end_date, next_occurrence`
- `is_active`
- `config (jsonb)`
- timestamps

### savings_goals
- `id (uuid, PK)`
- `name`
- `target_amount`
- `current_amount`
- `target_date`
- `status`
- `description`
- timestamps

---

## 🚀 Getting Started (Local Setup)

### Prerequisites
- Ruby (version per `.ruby-version`)
- Rails
- PostgreSQL

### Installation
1. Clone repo
   ```bash
   git clone https://github.com/Soni0709/vantage_backend.git
   cd vantage_backend

2. Install gems

bundle install


3. Setup database

rails db:create
rails db:migrate
rails db:seed   # if seeds exist


4. Start server

rails s


Backend runs at: http://localhost:3000