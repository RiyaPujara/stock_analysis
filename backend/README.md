# Stock Portfolio & Market Analyzer — Backend API

A complete **Node.js + TypeScript + Express + MongoDB (Mongoose)** REST API backend built specifically for the `stock_analysis` Flutter application.

---

## Architecture

```text
Flutter App (Web / Android / iOS / macOS)
    ↓
REST API (/api/v1)
    ↓
Routes (src/routes/)
    ↓
Controllers (src/controllers/)
    ↓
Services & Business Calculations (src/services/)
    ↓
Mongoose Models (src/models/)
    ↓
MongoDB Database (mongodb://127.0.0.1:27017/stock_analysis)
```

---

## Prerequisites

- **Node.js** >= 18.x
- **MongoDB** running locally on `127.0.0.1:27017` (or MongoDB Atlas URI)

---

## Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Default `.env` configuration:
```env
PORT=5001
NODE_ENV=development
MONGODB_URI=mongodb://127.0.0.1:27017/stock_analysis
JWT_SECRET=super_secret_stock_analyzer_jwt_key_2026
JWT_EXPIRES_IN=7d
MARKET_API_PROVIDER=mock_live
MARKET_CACHE_TTL_SECONDS=60
```

### 3. Seed Initial Database Data
Populate the demo user (`riya@example.com` / `password123`), Indian market indices (`NIFTY 50`, `SENSEX`), popular stocks (`RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`), initial portfolio holdings, watchlist, price alerts, and notifications:
```bash
npm run seed
```

### 4. Start the Backend Server
Development mode (hot-reload):
```bash
npm run dev
```

Production build & start:
```bash
npm run build
npm start
```

### 5. Run End-to-End API Tests
```bash
npx ts-node src/utils/test_api.ts
```

---

## Demo Credentials

- **Email:** `riya@example.com`
- **Password:** `password123`

---

## API Endpoints (`/api/v1`)

| Area | Method | Endpoint | Auth | Description |
|------|--------|----------|------|-------------|
| **Health** | `GET` | `/health` | No | Server health & status |
| **Auth** | `POST` | `/api/v1/auth/register` | No | Register a new user & initialize portfolio |
| **Auth** | `POST` | `/api/v1/auth/login` | No | Authenticate user & issue JWT |
| **Auth** | `GET` | `/api/v1/auth/me` | Yes | Get current user profile |
| **Auth** | `PUT` | `/api/v1/auth/profile` | Yes | Update user name/preferences |
| **Auth** | `PUT` | `/api/v1/auth/change-password` | Yes | Change user password |
| **Market** | `GET` | `/api/v1/market/indices` | No | Get NIFTY 50, SENSEX & market indices |
| **Market** | `GET` | `/api/v1/market/sectors` | No | Get market sector performance |
| **Stocks** | `GET` | `/api/v1/stocks?search=` | No | Search stocks by symbol or company name |
| **Stocks** | `GET` | `/api/v1/stocks/:symbol` | No | Get stock quote & market statistics |
| **Stocks** | `GET` | `/api/v1/stocks/:symbol/history` | No | Get historical OHLCV chart data (`1D`, `1W`, `1M`, `6M`, `1Y`) |
| **Stocks** | `GET` | `/api/v1/stocks/:symbol/fundamentals` | No | Get Market Cap, P/E Ratio, EPS, Dividend Yield |
| **Stocks** | `GET` | `/api/v1/stocks/:symbol/technicals` | No | Get RSI, MACD, Moving Averages, Support/Resistance |
| **Portfolio** | `GET` | `/api/v1/portfolio` | Yes | Get portfolio summary, total value, invested, P&L |
| **Portfolio** | `GET` | `/api/v1/portfolio/holdings` | Yes | Get holdings with live prices, gain/loss & allocation % |
| **Portfolio** | `POST` | `/api/v1/portfolio/holdings` | Yes | Record a BUY or SELL holding transaction |
| **Portfolio** | `DELETE` | `/api/v1/portfolio/holdings/:id` | Yes | Remove a holding |
| **Portfolio** | `GET` | `/api/v1/portfolio/transactions` | Yes | Get transaction history |
| **Portfolio** | `GET` | `/api/v1/portfolio/analytics` | Yes | Get advanced portfolio analytics & allocation |
| **Watchlist** | `GET` | `/api/v1/watchlist` | Yes | Get user's watchlisted stocks with live prices |
| **Watchlist** | `POST` | `/api/v1/watchlist` | Yes | Add stock symbol to watchlist |
| **Watchlist** | `DELETE` | `/api/v1/watchlist/:symbol` | Yes | Remove stock symbol from watchlist |
| **Alerts** | `GET` | `/api/v1/alerts` | Yes | List user's price alerts |
| **Alerts** | `POST` | `/api/v1/alerts` | Yes | Create a price alert (`ABOVE` / `BELOW`) |
| **Alerts** | `PATCH` | `/api/v1/alerts/:id/toggle` | Yes | Enable/disable a price alert |
| **Alerts** | `DELETE` | `/api/v1/alerts/:id` | Yes | Delete a price alert |
| **Notifications** | `GET` | `/api/v1/notifications` | Yes | List user notifications & unread count |
| **Notifications** | `PATCH` | `/api/v1/notifications/:id/read` | Yes | Mark notification as read |
| **Notifications** | `POST` | `/api/v1/notifications/mark-all-read` | Yes | Mark all notifications as read |
| **Notifications** | `DELETE` | `/api/v1/notifications` | Yes | Clear all notifications |
