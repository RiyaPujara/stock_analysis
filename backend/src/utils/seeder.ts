import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import { connectDB, closeDB } from '../config/database';
import { User, Stock, Portfolio, Holding, Transaction, Watchlist, Notification, MarketIndex } from '../models';
import { TransactionType } from '../types';

export const seedDatabase = async () => {
  try {
    await connectDB();
    console.log('[Seeder] Starting database seeding...');

    // Clear existing collections
    await Promise.all([
      User.deleteMany({}),
      Stock.deleteMany({}),
      Portfolio.deleteMany({}),
      Holding.deleteMany({}),
      Transaction.deleteMany({}),
      Watchlist.deleteMany({}),
      Notification.deleteMany({}),
      MarketIndex.deleteMany({}),
    ]);

    console.log('[Seeder] Cleared previous database collections.');

    // 1. Seed Market Indices
    await MarketIndex.create([
      { name: 'NIFTY 50', symbol: '^NSEI', currentValue: 25350.2, change: 181.5, changePercent: 0.72 },
      { name: 'SENSEX', symbol: '^BSESN', currentValue: 82450.3, change: 475.2, changePercent: 0.58 },
    ]);

    // 2. Seed Stocks
    const stocks = await Stock.create([
      {
        symbol: 'RELIANCE',
        companyName: 'Reliance Industries',
        exchange: 'NSE',
        sector: 'Energy',
        industry: 'Oil & Gas Refining',
        description: 'Reliance Industries is an Indian multinational conglomerate headquartered in Mumbai.',
        currentPrice: 2945.5,
        open: 2910.0,
        high: 2970.0,
        low: 2895.0,
        previousClose: 2909.1,
        change: 36.4,
        changePercent: 1.25,
        volume: 8420000,
        week52High: 3024.9,
        week52Low: 2221.0,
        marketCap: 19950000,
        peRatio: 24.82,
        eps: 118.62,
        roe: 14.5,
        debtToEquity: 0.42,
        revenueGrowth: 12.4,
        profitGrowth: 9.8,
        dividendYield: 0.38,
      },
      {
        symbol: 'TCS',
        companyName: 'Tata Consultancy Services',
        exchange: 'NSE',
        sector: 'IT',
        industry: 'IT Services & Consulting',
        description: 'Tata Consultancy Services is a global leader in IT services, consulting, and business solutions.',
        currentPrice: 4125.8,
        open: 4100.0,
        high: 4150.0,
        low: 4085.0,
        previousClose: 4092.2,
        change: 33.6,
        changePercent: 0.82,
        volume: 2450000,
        week52High: 4500.0,
        week52Low: 3300.0,
        marketCap: 14800000,
        peRatio: 29.5,
        eps: 139.8,
        roe: 48.0,
        debtToEquity: 0.05,
        revenueGrowth: 8.5,
        profitGrowth: 7.2,
        dividendYield: 1.2,
      },
      {
        symbol: 'INFY',
        companyName: 'Infosys',
        exchange: 'NSE',
        sector: 'IT',
        industry: 'IT Services & Consulting',
        description: 'Infosys Limited is a global leader in next-generation digital services and consulting.',
        currentPrice: 1485.2,
        open: 1495.0,
        high: 1502.0,
        low: 1478.0,
        previousClose: 1491.9,
        change: -6.7,
        changePercent: -0.45,
        volume: 4120000,
        week52High: 1750.0,
        week52Low: 1350.0,
        marketCap: 615000,
        peRatio: 23.4,
        eps: 63.4,
        roe: 31.0,
        debtToEquity: 0.1,
        revenueGrowth: 5.6,
        profitGrowth: 4.8,
        dividendYield: 2.3,
      },
      {
        symbol: 'HDFCBANK',
        companyName: 'HDFC Bank',
        exchange: 'NSE',
        sector: 'Banking',
        industry: 'Private Bank',
        description: 'HDFC Bank Limited is an Indian banking and financial services company headquartered in Mumbai.',
        currentPrice: 1875.4,
        open: 1860.0,
        high: 1885.0,
        low: 1855.0,
        previousClose: 1863.4,
        change: 12.0,
        changePercent: 0.64,
        volume: 9800000,
        week52High: 1950.0,
        week52Low: 1380.0,
        marketCap: 14200000,
        peRatio: 18.2,
        eps: 103.0,
        roe: 17.5,
        debtToEquity: 1.2,
        revenueGrowth: 15.0,
        profitGrowth: 16.5,
        dividendYield: 1.1,
      },
      {
        symbol: 'ICICIBANK',
        companyName: 'ICICI Bank',
        exchange: 'NSE',
        sector: 'Banking',
        industry: 'Private Bank',
        description: 'ICICI Bank is a leading Indian multinational bank and financial services company.',
        currentPrice: 1425.7,
        open: 1430.0,
        high: 1438.0,
        low: 1418.0,
        previousClose: 1428.7,
        change: -3.0,
        changePercent: -0.21,
        volume: 6700000,
        week52High: 1480.0,
        week52Low: 980.0,
        marketCap: 10000000,
        peRatio: 17.8,
        eps: 80.1,
        roe: 18.2,
        debtToEquity: 1.1,
        revenueGrowth: 18.2,
        profitGrowth: 20.1,
        dividendYield: 0.8,
      },
    ]);

    const stockMap = new Map(stocks.map((s) => [s.symbol, s]));

    // 3. Seed Demo User matching the Flutter UI ("Riya Pujara")
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('password123', salt);

    const demoUser = await User.create({
      name: 'Riya Pujara',
      email: 'riya@example.com',
      phone: '+91 98765 43210',
      passwordHash,
    });

    console.log(`[Seeder] Created demo user: ${demoUser.email} (password: password123)`);

    // 4. Create Portfolio for Demo User
    const portfolio = await Portfolio.create({
      userId: demoUser._id,
      name: 'Main Portfolio',
      description: 'Primary equity holdings',
    });

    // 5. Seed Holdings and Transactions matching the Flutter Portfolio Screens
    const relStock = stockMap.get('RELIANCE')!;
    const tcsStock = stockMap.get('TCS')!;
    const infyStock = stockMap.get('INFY')!;
    const hdfcStock = stockMap.get('HDFCBANK')!;

    await Holding.create([
      {
        portfolioId: portfolio._id,
        stockId: relStock._id,
        symbol: 'RELIANCE',
        companyName: relStock.companyName,
        quantity: 10,
        averageBuyPrice: 2850.0,
      },
      {
        portfolioId: portfolio._id,
        stockId: tcsStock._id,
        symbol: 'TCS',
        companyName: tcsStock.companyName,
        quantity: 5,
        averageBuyPrice: 3950.0,
      },
      {
        portfolioId: portfolio._id,
        stockId: infyStock._id,
        symbol: 'INFY',
        companyName: infyStock.companyName,
        quantity: 10,
        averageBuyPrice: 1520.0,
      },
      {
        portfolioId: portfolio._id,
        stockId: hdfcStock._id,
        symbol: 'HDFCBANK',
        companyName: hdfcStock.companyName,
        quantity: 8,
        averageBuyPrice: 1810.0,
      },
    ]);

    await Transaction.create([
      {
        portfolioId: portfolio._id,
        stockId: relStock._id,
        symbol: 'RELIANCE',
        type: TransactionType.BUY,
        quantity: 10,
        price: 2850.0,
        brokerage: 20.0,
        taxes: 5.5,
        totalAmount: 28525.5,
        transactionDate: new Date('2026-09-20T10:00:00Z'),
      },
      {
        portfolioId: portfolio._id,
        stockId: tcsStock._id,
        symbol: 'TCS',
        type: TransactionType.BUY,
        quantity: 5,
        price: 3950.0,
        brokerage: 20.0,
        taxes: 4.8,
        totalAmount: 19774.8,
        transactionDate: new Date('2026-09-18T11:30:00Z'),
      },
      {
        portfolioId: portfolio._id,
        stockId: infyStock._id,
        symbol: 'INFY',
        type: TransactionType.BUY,
        quantity: 10,
        price: 1520.0,
        brokerage: 20.0,
        taxes: 3.2,
        totalAmount: 15223.2,
        transactionDate: new Date('2026-09-15T14:15:00Z'),
      },
      {
        portfolioId: portfolio._id,
        stockId: hdfcStock._id,
        symbol: 'HDFCBANK',
        type: TransactionType.BUY,
        quantity: 8,
        price: 1810.0,
        brokerage: 20.0,
        taxes: 3.8,
        totalAmount: 14503.8,
        transactionDate: new Date('2026-09-12T09:45:00Z'),
      },
    ]);

    // 6. Seed Watchlist matching Flutter Watchlist Screen
    await Watchlist.create([
      { userId: demoUser._id, stockId: relStock._id, symbol: 'RELIANCE', companyName: relStock.companyName },
      { userId: demoUser._id, stockId: tcsStock._id, symbol: 'TCS', companyName: tcsStock.companyName },
      { userId: demoUser._id, stockId: infyStock._id, symbol: 'INFY', companyName: infyStock.companyName },
      { userId: demoUser._id, stockId: hdfcStock._id, symbol: 'HDFCBANK', companyName: hdfcStock.companyName },
      { userId: demoUser._id, stockId: stockMap.get('ICICIBANK')!._id, symbol: 'ICICIBANK', companyName: 'ICICI Bank' },
    ]);

    // 7. Seed Notifications matching Flutter Notification Screen
    await Notification.create([
      {
        userId: demoUser._id,
        title: 'Price Alert',
        message: 'Reliance Industries crossed ₹2,900.',
        type: 'PRICE_ALERT',
        isRead: false,
        createdAt: new Date(Date.now() - 10 * 60 * 1000),
      },
      {
        userId: demoUser._id,
        title: 'Portfolio Update',
        message: 'Your portfolio gained ₹1,250 today.',
        type: 'PORTFOLIO_UPDATE',
        isRead: false,
        createdAt: new Date(Date.now() - 60 * 60 * 1000),
      },
      {
        userId: demoUser._id,
        title: 'Market Update',
        message: 'NIFTY 50 is up by 0.72% today.',
        type: 'MARKET_UPDATE',
        isRead: true,
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
      },
      {
        userId: demoUser._id,
        title: 'Watchlist Alert',
        message: 'TCS price changed by +0.82%.',
        type: 'PRICE_ALERT',
        isRead: true,
        createdAt: new Date(Date.now() - 3 * 60 * 60 * 1000),
      },
      {
        userId: demoUser._id,
        title: 'Market Opening',
        message: 'Indian markets opened today at 9:15 AM.',
        type: 'MARKET_UPDATE',
        isRead: true,
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
      },
    ]);

    console.log('[Seeder] Database successfully populated with initial stocks, demo user, holdings, and watchlist.');
    await closeDB();
  } catch (error) {
    console.error('[Seeder] Failed to seed database:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  seedDatabase();
}
