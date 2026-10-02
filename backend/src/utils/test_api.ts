import dotenv from 'dotenv';
dotenv.config();

import http from 'http';
import app from '../app';
import { connectDB, closeDB } from '../config/database';

async function request(
  server: http.Server,
  method: string,
  path: string,
  body?: any,
  token?: string
): Promise<{ status: number; body: any }> {
  const port = (server.address() as any).port;
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : undefined;
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      },
      (res) => {
        let rawData = '';
        res.on('data', (chunk) => (rawData += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(rawData);
            resolve({ status: res.statusCode || 500, body: parsed });
          } catch {
            resolve({ status: res.statusCode || 500, body: rawData });
          }
        });
      }
    );

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function runTests() {
  await connectDB();
  const server = app.listen(0);
  console.log('[Tester] Test server started.');

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string, detail = '') {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${testName} - ${detail}`);
      failed++;
    }
  }

  try {
    console.log('\n--- 1. Health Check ---');
    const health = await request(server, 'GET', '/health');
    assert(health.status === 200 && health.body.data.status === 'healthy', 'GET /health returns healthy');

    console.log('\n--- 2. Authentication & User Profile Tests ---');
    // 2.1 Login demo user
    const loginRes = await request(server, 'POST', '/api/v1/auth/login', {
      email: 'riya@example.com',
      password: 'password123',
    });
    assert(loginRes.status === 200 && !!loginRes.body.data.token, 'Login demo user (riya@example.com)');
    const token = loginRes.body.data.token;

    // 2.2 Profile via /auth/me and /users/me (Flutter compatibility)
    const profileRes = await request(server, 'GET', '/api/v1/auth/me', undefined, token);
    assert(profileRes.status === 200 && profileRes.body.data.email === 'riya@example.com', 'GET /api/v1/auth/me');

    const usersMeRes = await request(server, 'GET', '/api/v1/users/me', undefined, token);
    assert(usersMeRes.status === 200 && usersMeRes.body.data.email === 'riya@example.com', 'GET /api/v1/users/me');

    const profileAliasRes = await request(server, 'GET', '/api/v1/auth/profile', undefined, token);
    assert(profileAliasRes.status === 200 && profileAliasRes.body.data.name === 'Riya Pujara', 'GET /api/v1/auth/profile');

    // 2.3 Invalid Login
    const invalidLogin = await request(server, 'POST', '/api/v1/auth/login', {
      email: 'riya@example.com',
      password: 'wrong_password',
    });
    assert(invalidLogin.status === 401, 'Reject invalid password with 401');

    // 2.4 Duplicate Register rejection
    const dupRegister = await request(server, 'POST', '/api/v1/auth/register', {
      name: 'Riya Pujara',
      email: 'riya@example.com',
      phone: '9876543210',
      password: 'password123',
    });
    assert(dupRegister.status === 409, 'Reject duplicate registration with 409');

    // 2.5 New user registration with auto portfolio and welcome notification
    const testEmail = `arjun_${Date.now()}@example.com`;
    const newRegister = await request(server, 'POST', '/api/v1/auth/register', {
      name: 'Arjun Verma',
      email: testEmail,
      phone: '+91 98200 12345',
      password: 'mypassword123',
    });
    assert(newRegister.status === 201 && !!newRegister.body?.data?.token, `Register new user (${testEmail})`);
    const arjunToken = newRegister.body.data.token;

    // 2.6 Update profile for Arjun
    const updateProfileRes = await request(
      server,
      'PUT',
      '/api/v1/auth/profile',
      { name: 'Arjun V. Sharma', phone: '+91 98200 99999' },
      arjunToken
    );
    assert(updateProfileRes.status === 200 && updateProfileRes.body.data.name === 'Arjun V. Sharma', 'PUT /api/v1/auth/profile updates profile');

    // 2.7 Change password for Arjun
    const changePwdRes = await request(
      server,
      'PUT',
      '/api/v1/auth/change-password',
      { currentPassword: 'mypassword123', newPassword: 'newsecurepass456' },
      arjunToken
    );
    assert(changePwdRes.status === 200, 'PUT /api/v1/auth/change-password succeeds');

    // 2.8 Verify new password login
    const reloginRes = await request(server, 'POST', '/api/v1/auth/login', {
      email: testEmail,
      password: 'newsecurepass456',
    });
    assert(reloginRes.status === 200 && !!reloginRes.body.data.token, 'Login with updated password succeeds');

    // 2.9 Unauthorized requests rejected
    const unauthRes = await request(server, 'GET', '/api/v1/auth/me');
    assert(unauthRes.status === 401, 'Reject request without token with 401');

    console.log('\n--- 3. Market & Stock Tests ---');
    const indicesRes = await request(server, 'GET', '/api/v1/market/indices');
    assert(indicesRes.status === 200 && indicesRes.body.data.length >= 2, 'GET /api/v1/market/indices returns NIFTY & SENSEX');

    const sectorsRes = await request(server, 'GET', '/api/v1/market/sectors');
    assert(sectorsRes.status === 200 && sectorsRes.body.data.length >= 2, 'GET /api/v1/market/sectors returns sectors');

    // All stocks
    const allStocksRes = await request(server, 'GET', '/api/v1/stocks');
    assert(allStocksRes.status === 200 && allStocksRes.body.data.length >= 5, 'GET /api/v1/stocks returns all active stocks');

    // Search query
    const searchRes = await request(server, 'GET', '/api/v1/stocks?search=reliance');
    assert(searchRes.status === 200 && searchRes.body.data[0].symbol === 'RELIANCE', 'Search stocks returns RELIANCE');
    assert(searchRes.body.data[0].companyName === 'Reliance Industries', 'Stock includes companyName and formatted price');

    // Stock details by symbol
    const stockDetails = await request(server, 'GET', '/api/v1/stocks/RELIANCE');
    assert(stockDetails.status === 200 && stockDetails.body.data.currentPrice > 0, 'GET /api/v1/stocks/RELIANCE details');
    const stockId = stockDetails.body.data.id;

    // Stock details by ObjectId
    const stockByIdRes = await request(server, 'GET', `/api/v1/stocks/${stockId}`);
    assert(stockByIdRes.status === 200 && stockByIdRes.body.data.symbol === 'RELIANCE', 'GET /api/v1/stocks/:id lookup by ObjectId');

    // Historical chart for 1D, 1W, 1M
    const history1D = await request(server, 'GET', '/api/v1/stocks/RELIANCE/history?period=1D');
    assert(history1D.status === 200 && history1D.body.data.length >= 12, 'GET /stocks/RELIANCE/history?period=1D (12+ points)');

    const history1W = await request(server, 'GET', '/api/v1/stocks/RELIANCE/history?period=1W');
    assert(history1W.status === 200 && history1W.body.data.length >= 7, 'GET /stocks/RELIANCE/history?period=1W (7+ points)');

    const history1M = await request(server, 'GET', '/api/v1/stocks/RELIANCE/history?period=1M');
    assert(history1M.status === 200 && history1M.body.data.length >= 30, 'GET /stocks/RELIANCE/history?period=1M (30+ points)');

    // Fundamentals
    const fundRes = await request(server, 'GET', '/api/v1/stocks/RELIANCE/fundamentals');
    assert(fundRes.status === 200 && fundRes.body.data.peRatio > 0, 'GET fundamentals peRatio');

    // Technicals
    const techRes = await request(server, 'GET', '/api/v1/stocks/RELIANCE/technicals');
    assert(techRes.status === 200 && techRes.body.data.rsi > 0 && techRes.body.data.macd !== undefined, 'GET technicals RSI and MACD');

    // Non-existent stock returns 404
    const notFoundStock = await request(server, 'GET', '/api/v1/stocks/NONEXISTENT999');
    assert(notFoundStock.status === 404, 'GET /stocks/NONEXISTENT999 returns 404');

    console.log('\n--- 4. Portfolio & Business Logic Tests ---');
    // Root portfolio alias
    const rootPortfolioRes = await request(server, 'GET', '/api/v1/portfolio', undefined, token);
    assert(rootPortfolioRes.status === 200 && rootPortfolioRes.body.data.totalValue > 0, 'GET /api/v1/portfolio returns summary');

    const summaryRes = await request(server, 'GET', '/api/v1/portfolio/summary', undefined, token);
    assert(
      summaryRes.status === 200 &&
        summaryRes.body.data.totalValue > 0 &&
        summaryRes.body.data.investedValue > 0 &&
        summaryRes.body.data.totalInvested !== undefined &&
        summaryRes.body.data.totalGainLoss !== undefined,
      'Portfolio summary calculates valuation, invested value and dual field aliases'
    );
    assert(summaryRes.body.data.stockAllocation.length > 0, 'Portfolio summary calculates dynamic stock allocation');

    const holdingsRes = await request(server, 'GET', '/api/v1/portfolio/holdings', undefined, token);
    assert(holdingsRes.status === 200 && holdingsRes.body.data.length >= 4, 'GET /api/v1/portfolio/holdings returns 4 holdings');

    // Test BUY 5 RELIANCE @ 3000
    const addTxRes = await request(
      server,
      'POST',
      '/api/v1/portfolio/holdings',
      {
        symbol: 'RELIANCE',
        exchange: 'NSE',
        type: 'BUY',
        quantity: 5,
        price: 3000,
        brokerage: 20,
        taxes: 5,
      },
      token
    );
    assert(addTxRes.status === 201, 'POST /api/v1/portfolio/holdings records BUY transaction');
    const updatedQty = addTxRes.body.data.holding.quantity;
    assert(updatedQty > 10, 'Holding quantity increased on BUY');

    // Test SELL 2 RELIANCE @ 3100
    const sellTxRes = await request(
      server,
      'POST',
      '/api/v1/portfolio/holdings',
      {
        symbol: 'RELIANCE',
        exchange: 'NSE',
        type: 'SELL',
        quantity: 2,
        price: 3100,
        brokerage: 15,
        taxes: 3,
      },
      token
    );
    assert(sellTxRes.status === 201, 'POST /api/v1/portfolio/holdings records SELL transaction');
    assert(sellTxRes.body.data.holding.quantity === updatedQty - 2, 'Holding quantity decreased on SELL');

    // Test BUY WIPRO and then DELETE WIPRO holding
    const buyWiproRes = await request(
      server,
      'POST',
      '/api/v1/portfolio/holdings',
      {
        symbol: 'WIPRO',
        exchange: 'NSE',
        type: 'BUY',
        quantity: 25,
        price: 520,
      },
      token
    );
    assert(buyWiproRes.status === 201, 'Add new holding for WIPRO');
    const wiproHoldingId = buyWiproRes.body.data.holding.id;

    const deleteHoldingRes = await request(
      server,
      'DELETE',
      `/api/v1/portfolio/holdings/${wiproHoldingId}`,
      undefined,
      token
    );
    assert(deleteHoldingRes.status === 200, 'DELETE /api/v1/portfolio/holdings/:id removes holding');

    const txListRes = await request(server, 'GET', '/api/v1/portfolio/transactions', undefined, token);
    assert(txListRes.status === 200 && txListRes.body.data.length >= 6, 'Transaction ledger logs all BUY/SELL operations');

    const analyticsRes = await request(server, 'GET', '/api/v1/portfolio/analytics', undefined, token);
    assert(analyticsRes.status === 200 && analyticsRes.body.data.performanceLeaders.length > 0, 'GET analytics performance leaders');
    assert(analyticsRes.body.data.riskDiversification.diversification !== undefined, 'Analytics includes risk diversification');

    console.log('\n--- 5. Watchlist Tests ---');
    // 5.1 GET watchlist
    const watchlistRes = await request(server, 'GET', '/api/v1/watchlist', undefined, token);
    assert(watchlistRes.status === 200 && watchlistRes.body.data.length >= 1, 'GET /api/v1/watchlist returns watchlist items');
    assert(watchlistRes.body.data[0].currentPrice !== undefined, 'Watchlist items include currentPrice and changePercent');

    // 5.2 POST watchlist add stock
    const addWatchRes = await request(server, 'POST', '/api/v1/watchlist', { symbol: 'TCS' }, token);
    assert(addWatchRes.status === 201 || addWatchRes.status === 200, 'POST /api/v1/watchlist adds TCS');
    const tcsWatchId = addWatchRes.body.data.id;

    // 5.3 POST duplicate watchlist item (idempotent)
    const dupWatchRes = await request(server, 'POST', '/api/v1/watchlist', { symbol: 'TCS' }, token);
    assert(dupWatchRes.status === 200 || dupWatchRes.status === 201, 'POST duplicate stock to watchlist returns existing item');

    // 5.4 DELETE by symbol
    const removeWatchlistBySymbol = await request(server, 'DELETE', '/api/v1/watchlist/TCS', undefined, token);
    assert(removeWatchlistBySymbol.status === 200, 'DELETE /api/v1/watchlist/TCS by symbol');

    // 5.5 DELETE by ObjectId (re-add and delete by ID)
    const reAddRes = await request(server, 'POST', '/api/v1/watchlist', { symbol: 'INFY' }, token);
    const infyWatchId = reAddRes.body.data.id;
    const removeWatchlistById = await request(server, 'DELETE', `/api/v1/watchlist/${infyWatchId}`, undefined, token);
    assert(removeWatchlistById.status === 200, 'DELETE /api/v1/watchlist/:id by ObjectId');

    console.log('\n--- 6. Price Alerts & Background Worker Tests ---');
    // 6.1 Create Price Alert (ABOVE)
    const createAlertRes = await request(
      server,
      'POST',
      '/api/v1/alerts',
      {
        symbol: 'RELIANCE',
        targetPrice: 3500,
        condition: 'ABOVE',
      },
      token
    );
    assert(createAlertRes.status === 201, 'POST /api/v1/alerts creates ABOVE alert');
    const alertId = createAlertRes.body.data.id;

    // 6.2 Create Price Alert (BELOW)
    const createBelowAlert = await request(
      server,
      'POST',
      '/api/v1/alerts',
      {
        symbol: 'TCS',
        targetPrice: 3800,
        condition: 'BELOW',
      },
      token
    );
    assert(createBelowAlert.status === 201, 'POST /api/v1/alerts creates BELOW alert');
    const belowAlertId = createBelowAlert.body.data.id;

    // 6.3 List alerts
    const listAlertsRes = await request(server, 'GET', '/api/v1/alerts', undefined, token);
    assert(listAlertsRes.status === 200 && listAlertsRes.body.data.length >= 2, 'GET /api/v1/alerts lists active alerts');

    // 6.4 PATCH /alerts/:id/toggle
    const toggleOffRes = await request(server, 'PATCH', `/api/v1/alerts/${alertId}/toggle`, undefined, token);
    assert(toggleOffRes.status === 200 && toggleOffRes.body.data.isActive === false, 'PATCH /api/v1/alerts/:id/toggle deactivates alert');

    const toggleOnRes = await request(server, 'PATCH', `/api/v1/alerts/${alertId}/toggle`, undefined, token);
    assert(toggleOnRes.status === 200 && toggleOnRes.body.data.isActive === true, 'PATCH /api/v1/alerts/:id/toggle reactivates alert');

    // 6.5 Background Alert Worker trigger test:
    // Create an alert that is guaranteed to trigger immediately (RELIANCE price is > 2000)
    const triggerableAlert = await request(
      server,
      'POST',
      '/api/v1/alerts',
      {
        symbol: 'RELIANCE',
        targetPrice: 2000,
        condition: 'ABOVE',
      },
      token
    );
    assert(triggerableAlert.status === 201, 'Create triggerable alert (RELIANCE ABOVE 2000)');
    const triggerableId = triggerableAlert.body.data.id;

    // Trigger alert evaluation worker
    const workerRes = await request(server, 'POST', '/api/v1/alerts/check', undefined, token);
    assert(workerRes.status === 200 && workerRes.body.data.triggeredCount >= 1, 'Alert worker triggers threshold evaluation');

    // Verify alert is marked isTriggered: true
    const updatedAlerts = await request(server, 'GET', '/api/v1/alerts', undefined, token);
    const triggeredItem = updatedAlerts.body.data.find((a: any) => a.id === triggerableId);
    assert(triggeredItem && triggeredItem.isTriggered === true, 'Alert marked isTriggered = true after worker evaluation');

    // 6.6 DELETE /alerts/:id
    const deleteAlertRes = await request(server, 'DELETE', `/api/v1/alerts/${alertId}`, undefined, token);
    assert(deleteAlertRes.status === 200, 'DELETE /api/v1/alerts/:id deletes alert');
    await request(server, 'DELETE', `/api/v1/alerts/${belowAlertId}`, undefined, token);
    await request(server, 'DELETE', `/api/v1/alerts/${triggerableId}`, undefined, token);

    console.log('\n--- 7. Notifications Tests ---');
    // 7.1 GET /notifications
    const notifsRes = await request(server, 'GET', '/api/v1/notifications', undefined, token);
    assert(notifsRes.status === 200 && notifsRes.body.data.length >= 1, 'GET /api/v1/notifications lists notifications');
    
    // Verify an alert-generated notification is present
    const priceAlertNotif = notifsRes.body.data.find((n: any) => n.type === 'PRICE_ALERT');
    assert(!!priceAlertNotif, 'Automated PRICE_ALERT notification was created by background worker');

    // 7.2 PATCH /notifications/:id/read
    const notifId = notifsRes.body.data[0].id;
    const markReadRes = await request(server, 'PATCH', `/api/v1/notifications/${notifId}/read`, undefined, token);
    assert(markReadRes.status === 200 && markReadRes.body.data.isRead === true, 'PATCH /api/v1/notifications/:id/read marks as read');

    // 7.3 POST /notifications/mark-all-read
    const markAllReadRes = await request(server, 'POST', '/api/v1/notifications/mark-all-read', undefined, token);
    assert(markAllReadRes.status === 200, 'POST /api/v1/notifications/mark-all-read');

    // 7.4 DELETE /notifications/:id (single notification)
    const deleteSingleNotif = await request(server, 'DELETE', `/api/v1/notifications/${notifId}`, undefined, token);
    assert(deleteSingleNotif.status === 200, 'DELETE /api/v1/notifications/:id deletes single notification');

    // 7.5 DELETE /notifications (clear all)
    const clearAllNotifs = await request(server, 'DELETE', '/api/v1/notifications', undefined, token);
    assert(clearAllNotifs.status === 200, 'DELETE /api/v1/notifications clears all remaining notifications');

    const emptyNotifs = await request(server, 'GET', '/api/v1/notifications', undefined, token);
    assert(emptyNotifs.status === 200 && emptyNotifs.body.data.length === 0, 'Notifications list is empty after clear all');

    console.log(`\n========================================`);
    console.log(`Tests Completed: ${passed} Passed, ${failed} Failed`);
    console.log(`========================================\n`);

    if (failed > 0) {
      process.exit(1);
    }
  } finally {
    server.close();
    await closeDB();
  }
}

runTests();
