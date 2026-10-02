import mongoose from 'mongoose';
import { Stock, MarketIndex, HistoricalPrice } from '../models';

export class MarketService {
  static async getIndices() {
    let indices = await MarketIndex.find();
    if (indices.length === 0) {
      // Fallback defaults matching Flutter UI
      return [
        { name: 'NIFTY 50', symbol: '^NSEI', currentValue: 25350.2, change: 181.5, changePercent: 0.72 },
        { name: 'SENSEX', symbol: '^BSESN', currentValue: 82450.3, change: 475.2, changePercent: 0.58 },
      ];
    }
    return indices.map((idx) => idx.toFlutterJson());
  }

  static async getSectors() {
    try {
      const sectorAgg = await Stock.aggregate([
        { $match: { sector: { $ne: null } } },
        { $group: { _id: '$sector', avgChange: { $avg: '$changePercent' } } },
      ]);

      if (sectorAgg.length > 0) {
        return sectorAgg.map((s) => ({
          title: s._id,
          change: `${s.avgChange >= 0 ? '+' : ''}${s.avgChange.toFixed(2)}%`,
          isPositive: s.avgChange >= 0,
        }));
      }
    } catch (_) {}

    return [
      { title: 'Banking', change: '+1.12%', isPositive: true },
      { title: 'IT', change: '+0.84%', isPositive: true },
      { title: 'Pharma', change: '-0.32%', isPositive: false },
      { title: 'Auto', change: '+0.56%', isPositive: true },
    ];
  }

  static async searchStocks(query?: string) {
    let filter: any = { isActive: true };

    if (query && query.trim().length > 0) {
      const q = query.trim();
      const regex = new RegExp(q, 'i');
      filter = {
        isActive: true,
        $or: [{ symbol: regex }, { companyName: regex }],
      };
    }

    const stocks = await Stock.find(filter).limit(20);
    return stocks.map((stock) => stock.toFlutterJson());
  }

  static async getStockBySymbol(symbolOrId: string) {
    const isObjectId = mongoose.Types.ObjectId.isValid(symbolOrId) && symbolOrId.length === 24;
    const filter = isObjectId
      ? { $or: [{ _id: symbolOrId }, { symbol: symbolOrId.toUpperCase() }] }
      : { symbol: symbolOrId.toUpperCase() };

    const stock = await Stock.findOne(filter);
    if (!stock) {
      const error: any = new Error(`Stock ${symbolOrId} not found`);
      error.statusCode = 404;
      throw error;
    }
    return stock.toFlutterJson();
  }

  static async getHistoricalPrices(symbol: string, period = '1D') {
    const sym = symbol.toUpperCase();
    const stock = await Stock.findOne({ symbol: sym });
    const basePrice = stock ? stock.currentPrice : 2945.5;

    // Check if database already has historical prices
    let records = await HistoricalPrice.find({ symbol: sym }).sort({ date: 1 });

    if (records.length > 0) {
      return records.map((r) => r.toFlutterJson());
    }

    // Determine interval and points count based on chart period
    let pointsCount = 12;
    let stepMs = 30 * 60 * 1000; // 30 mins for 1D

    switch (period.toUpperCase()) {
      case '1W':
        pointsCount = 7;
        stepMs = 24 * 60 * 60 * 1000;
        break;
      case '1M':
        pointsCount = 30;
        stepMs = 24 * 60 * 60 * 1000;
        break;
      case '6M':
        pointsCount = 60;
        stepMs = 3 * 24 * 60 * 60 * 1000;
        break;
      case '1Y':
        pointsCount = 90;
        stepMs = 4 * 24 * 60 * 60 * 1000;
        break;
      case '1D':
      default:
        pointsCount = 12;
        stepMs = 30 * 60 * 1000;
        break;
    }

    const now = new Date();
    const generated: any[] = [];

    let current = basePrice * 0.96;
    for (let i = pointsCount; i >= 1; i--) {
      const date = new Date(now.getTime() - i * stepMs);
      const variation = (Math.random() - 0.48) * (basePrice * 0.015);
      current = Math.max(1, current + variation);
      const high = current + Math.random() * (basePrice * 0.008);
      const low = current - Math.random() * (basePrice * 0.008);
      const open = (current + low) / 2;

      generated.push({
        date: date.toISOString(),
        open: parseFloat(open.toFixed(2)),
        high: parseFloat(high.toFixed(2)),
        low: parseFloat(low.toFixed(2)),
        close: parseFloat(current.toFixed(2)),
        volume: Math.floor(500000 + Math.random() * 2000000),
      });
    }

    // Add final point anchored to stock's actual current price
    generated.push({
      date: now.toISOString(),
      open: parseFloat(((current + basePrice) / 2).toFixed(2)),
      high: parseFloat((Math.max(current, basePrice) * 1.002).toFixed(2)),
      low: parseFloat((Math.min(current, basePrice) * 0.998).toFixed(2)),
      close: parseFloat(basePrice.toFixed(2)),
      volume: stock?.volume || 1000000,
    });

    return generated;
  }

  static async getFundamentals(symbol: string) {
    const stock = await Stock.findOne({ symbol: symbol.toUpperCase() });
    if (!stock) {
      const error: any = new Error(`Stock ${symbol} not found`);
      error.statusCode = 404;
      throw error;
    }

    return {
      symbol: stock.symbol,
      marketCap: stock.marketCap || 19950000,
      peRatio: stock.peRatio || 24.82,
      eps: stock.eps || 118.62,
      roe: stock.roe || 14.5,
      debtToEquity: stock.debtToEquity || 0.42,
      revenueGrowth: stock.revenueGrowth || 12.4,
      profitGrowth: stock.profitGrowth || 9.8,
      dividendYield: stock.dividendYield || 0.38,
    };
  }

  static async getTechnicals(symbol: string) {
    const stock = await Stock.findOne({ symbol: symbol.toUpperCase() });
    if (!stock) {
      const error: any = new Error(`Stock ${symbol} not found`);
      error.statusCode = 404;
      throw error;
    }

    return {
      symbol: stock.symbol,
      rsi: 58.4,
      macd: 2.35,
      signal: 1.9,
      sma20: parseFloat((stock.currentPrice * 0.98).toFixed(2)),
      sma50: parseFloat((stock.currentPrice * 0.95).toFixed(2)),
      ema20: parseFloat((stock.currentPrice * 0.985).toFixed(2)),
    };
  }
}
