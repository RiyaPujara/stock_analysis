import { Watchlist, Stock } from '../models';

export class WatchlistService {
  static async getWatchlist(userId: string) {
    const items = await Watchlist.find({ userId });
    const stockIds = items.map((i) => i.stockId);
    const stocks = await Stock.find({ _id: { $in: stockIds } });
    const stockMap = new Map(stocks.map((s) => [s._id.toString(), s]));

    return items.map((item) => {
      const stock = stockMap.get(item.stockId.toString());
      const currentPrice = stock ? stock.currentPrice : 0;
      const change = stock ? stock.change : 0;
      const changePercent = stock ? stock.changePercent : 0;

      return {
        id: item._id.toString(),
        userId: item.userId.toString(),
        stockId: item.stockId.toString(),
        symbol: item.symbol,
        name: item.companyName,
        companyName: item.companyName,
        currentPrice: currentPrice,
        price: `₹${currentPrice.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
        priceNum: currentPrice,
        change: `${change >= 0 ? '+' : ''}${changePercent.toFixed(2)}%`,
        changePercent: changePercent,
        isPositive: change >= 0,
        addedAt: item.addedAt.toISOString(),
      };
    });
  }

  static async addToWatchlist(userId: string, symbol: string) {
    const sym = symbol.toUpperCase();
    let stock = await Stock.findOne({ symbol: sym });
    if (!stock) {
      const error: any = new Error(`Stock ${sym} not found`);
      error.statusCode = 404;
      throw error;
    }

    const existing = await Watchlist.findOne({ userId, stockId: stock._id });
    if (existing) {
      return {
        id: existing._id.toString(),
        userId: existing.userId.toString(),
        stockId: existing.stockId.toString(),
        symbol: existing.symbol,
        companyName: existing.companyName,
        addedAt: existing.addedAt.toISOString(),
      };
    }

    const item = await Watchlist.create({
      userId,
      stockId: stock._id,
      symbol: stock.symbol,
      companyName: stock.companyName,
    });

    return item.toFlutterJson();
  }

  static async removeFromWatchlist(userId: string, stockIdOrSymbol: string) {
    const isObjectId = /^[0-9a-fA-F]{24}$/.test(stockIdOrSymbol);
    if (isObjectId) {
      await Watchlist.findOneAndDelete({
        userId,
        $or: [{ _id: stockIdOrSymbol }, { stockId: stockIdOrSymbol }],
      });
    } else {
      await Watchlist.findOneAndDelete({
        userId,
        symbol: stockIdOrSymbol.toUpperCase(),
      });
    }

    return { message: 'Removed from watchlist successfully' };
  }
}
