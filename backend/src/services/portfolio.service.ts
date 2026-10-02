import mongoose from 'mongoose';
import { Portfolio, Holding, Transaction, Stock } from '../models';
import { TransactionType } from '../types';

export class PortfolioService {
  static async getOrCreatePortfolio(userId: string) {
    let portfolio = await Portfolio.findOne({ userId });
    if (!portfolio) {
      portfolio = await Portfolio.create({
        userId,
        name: 'Primary Portfolio',
        description: 'Personal stock investment portfolio',
      });
    }
    return portfolio;
  }

  static async getPortfolioSummary(userId: string) {
    const portfolio = await this.getOrCreatePortfolio(userId);
    const holdings = await Holding.find({ portfolioId: portfolio._id });

    if (holdings.length === 0) {
      return {
        portfolioId: portfolio._id.toString(),
        totalValue: 0.0,
        investedValue: 0.0,
        totalGain: 0.0,
        totalGainPercent: 0.0,
        todayGain: 0.0,
        todayGainPercent: 0.0,
        holdingsCount: 0,
        assetAllocation: [
          { name: 'Stocks', percentage: '0%', value: '₹0' },
          { name: 'Cash', percentage: '100%', value: '₹0' },
          { name: 'Other', percentage: '0%', value: '₹0' },
        ],
        stockAllocation: [],
      };
    }

    // Fetch stock quotes for all holdings
    const stockIds = holdings.map((h) => h.stockId);
    const stocks = await Stock.find({ _id: { $in: stockIds } });
    const stockMap = new Map(stocks.map((s) => [s._id.toString(), s]));

    let totalInvested = 0;
    let totalCurrentValue = 0;
    let totalTodayGain = 0;
    const stockAllocationItems: any[] = [];

    for (const holding of holdings) {
      const stock = stockMap.get(holding.stockId.toString());
      const currentPrice = stock ? stock.currentPrice : holding.averageBuyPrice;
      const dayChange = stock ? stock.change : 0;

      const invested = holding.quantity * holding.averageBuyPrice;
      const currentVal = holding.quantity * currentPrice;
      const todayChange = holding.quantity * dayChange;

      totalInvested += invested;
      totalCurrentValue += currentVal;
      totalTodayGain += todayChange;

      stockAllocationItems.push({
        stockId: holding.stockId.toString(),
        symbol: holding.symbol,
        name: holding.companyName,
        valueNum: currentVal,
        value: `₹${currentVal.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`,
      });
    }

    const totalGain = totalCurrentValue - totalInvested;
    const totalGainPercent = totalInvested > 0 ? (totalGain / totalInvested) * 100 : 0;
    const previousDayTotal = totalCurrentValue - totalTodayGain;
    const todayGainPercent = previousDayTotal > 0 ? (totalTodayGain / previousDayTotal) * 100 : 0;

    // Calculate dynamic stock allocation percentages
    const formattedStockAllocation = stockAllocationItems.map((item) => {
      const pct = totalCurrentValue > 0 ? (item.valueNum / totalCurrentValue) * 100 : 0;
      return {
        stockId: item.stockId,
        symbol: item.symbol,
        name: item.name,
        percentage: `${pct.toFixed(1)}%`,
        value: item.value,
      };
    });

    const totalGainVal = parseFloat(totalGain.toFixed(2));
    const totalGainPctVal = parseFloat(totalGainPercent.toFixed(2));
    const investedVal = parseFloat(totalInvested.toFixed(2));

    return {
      portfolioId: portfolio._id.toString(),
      totalValue: parseFloat(totalCurrentValue.toFixed(2)),
      investedValue: investedVal,
      totalInvested: investedVal,
      totalGain: totalGainVal,
      totalGainLoss: totalGainVal,
      totalGainPercent: totalGainPctVal,
      totalGainLossPercent: totalGainPctVal,
      todayGain: parseFloat(totalTodayGain.toFixed(2)),
      todayGainPercent: parseFloat(todayGainPercent.toFixed(2)),
      holdingsCount: holdings.length,
      assetAllocation: [
        { name: 'Stocks', percentage: '80%', value: `₹${(totalCurrentValue * 0.8).toLocaleString('en-IN', { maximumFractionDigits: 0 })}` },
        { name: 'Cash', percentage: '15%', value: `₹${(totalCurrentValue * 0.15).toLocaleString('en-IN', { maximumFractionDigits: 0 })}` },
        { name: 'Other', percentage: '5%', value: `₹${(totalCurrentValue * 0.05).toLocaleString('en-IN', { maximumFractionDigits: 0 })}` },
      ],
      stockAllocation: formattedStockAllocation,
    };
  }

  static async getHoldings(userId: string) {
    const portfolio = await this.getOrCreatePortfolio(userId);
    const holdings = await Holding.find({ portfolioId: portfolio._id });

    const stockIds = holdings.map((h) => h.stockId);
    const stocks = await Stock.find({ _id: { $in: stockIds } });
    const stockMap = new Map(stocks.map((s) => [s._id.toString(), s]));

    return holdings.map((holding) => {
      const stock = stockMap.get(holding.stockId.toString());
      const currentPrice = stock ? stock.currentPrice : holding.averageBuyPrice;
      const currentValue = holding.quantity * currentPrice;
      const investedValue = holding.quantity * holding.averageBuyPrice;
      const gain = currentValue - investedValue;
      const gainPercent = investedValue > 0 ? (gain / investedValue) * 100 : 0;

      return {
        id: holding._id.toString(),
        portfolioId: holding.portfolioId.toString(),
        stockId: holding.stockId.toString(),
        symbol: holding.symbol,
        companyName: holding.companyName,
        quantity: holding.quantity,
        averageBuyPrice: holding.averageBuyPrice,
        currentPrice,
        currentValue: parseFloat(currentValue.toFixed(2)),
        gain: parseFloat(gain.toFixed(2)),
        gainPercent: parseFloat(gainPercent.toFixed(2)),
        isPositive: gain >= 0,
      };
    });
  }

  static async addTransaction(
    userId: string,
    data: {
      symbol: string;
      exchange: 'NSE' | 'BSE';
      type: 'BUY' | 'SELL';
      quantity: number;
      price: number;
      brokerage?: number;
      taxes?: number;
    }
  ) {
    const portfolio = await this.getOrCreatePortfolio(userId);

    // Find or automatically create stock in catalog
    let stock = await Stock.findOne({ symbol: data.symbol.toUpperCase() });
    if (!stock) {
      stock = await Stock.create({
        symbol: data.symbol.toUpperCase(),
        companyName: data.symbol.toUpperCase(),
        exchange: data.exchange || 'NSE',
        currentPrice: data.price,
        open: data.price,
        high: data.price,
        low: data.price,
        previousClose: data.price,
        change: 0,
        changePercent: 0,
        volume: 100000,
      });
    }

    const brokerage = data.brokerage || 0;
    const taxes = data.taxes || 0;
    const totalAmount =
      data.type === 'BUY'
        ? data.quantity * data.price + brokerage + taxes
        : data.quantity * data.price - brokerage - taxes;

    // Record internal transaction log
    const transaction = await Transaction.create({
      portfolioId: portfolio._id,
      stockId: stock._id,
      symbol: stock.symbol,
      type: data.type === 'BUY' ? TransactionType.BUY : TransactionType.SELL,
      quantity: data.quantity,
      price: data.price,
      brokerage,
      taxes,
      totalAmount,
      transactionDate: new Date(),
    });

    // Update holdings accordingly
    let holding = await Holding.findOne({
      portfolioId: portfolio._id,
      stockId: stock._id,
    });

    if (data.type === 'BUY') {
      if (holding) {
        const totalOldCost = holding.quantity * holding.averageBuyPrice;
        const totalNewCost = data.quantity * data.price;
        const combinedQuantity = holding.quantity + data.quantity;
        const weightedAvg = (totalOldCost + totalNewCost) / combinedQuantity;

        holding.quantity = combinedQuantity;
        holding.averageBuyPrice = parseFloat(weightedAvg.toFixed(2));
        await holding.save();
      } else {
        holding = await Holding.create({
          portfolioId: portfolio._id,
          stockId: stock._id,
          symbol: stock.symbol,
          companyName: stock.companyName,
          quantity: data.quantity,
          averageBuyPrice: data.price,
        });
      }
    } else {
      // SELL
      if (!holding || holding.quantity < data.quantity) {
        const error: any = new Error(`Cannot sell ${data.quantity} shares; you only own ${holding ? holding.quantity : 0}`);
        error.statusCode = 400;
        throw error;
      }

      holding.quantity -= data.quantity;
      if (holding.quantity <= 0) {
        await Holding.findByIdAndDelete(holding._id);
        holding = null as any;
      } else {
        await holding.save();
      }
    }

    return {
      transaction: transaction.toFlutterJson(),
      holding: holding ? holding.toFlutterJson() : null,
    };
  }

  static async deleteHolding(userId: string, holdingId: string) {
    const portfolio = await this.getOrCreatePortfolio(userId);
    const isObjectId = mongoose.Types.ObjectId.isValid(holdingId) && holdingId.length === 24;
    const filter = isObjectId
      ? { _id: holdingId, portfolioId: portfolio._id }
      : { symbol: holdingId.toUpperCase(), portfolioId: portfolio._id };

    const holding = await Holding.findOne(filter);
    if (!holding) {
      const error: any = new Error('Holding not found in your portfolio');
      error.statusCode = 404;
      throw error;
    }

    await Holding.findByIdAndDelete(holding._id);
    return { message: `Holding ${holding.symbol} removed successfully` };
  }

  static async getTransactions(userId: string) {
    const portfolio = await this.getOrCreatePortfolio(userId);
    const transactions = await Transaction.find({ portfolioId: portfolio._id })
      .sort({ transactionDate: -1 })
      .limit(50);

    const stockIds = transactions.map((t) => t.stockId);
    const stocks = await Stock.find({ _id: { $in: stockIds } });
    const stockMap = new Map(stocks.map((s) => [s._id.toString(), s]));

    return transactions.map((t) => {
      const stock = stockMap.get(t.stockId.toString());
      return {
        id: t._id.toString(),
        portfolioId: t.portfolioId.toString(),
        stockId: t.stockId.toString(),
        symbol: t.symbol,
        companyName: stock ? stock.companyName : t.symbol,
        type: t.type,
        quantity: t.quantity,
        price: t.price,
        brokerage: t.brokerage,
        taxes: t.taxes,
        totalAmount: t.totalAmount,
        transactionDate: t.transactionDate.toISOString(),
      };
    });
  }

  static async getAnalytics(userId: string) {
    const summary = await this.getPortfolioSummary(userId);
    const holdings = await this.getHoldings(userId);

    // Rank winners and losers
    const sorted = [...holdings].sort((a, b) => b.gainPercent - a.gainPercent);
    const leaders = sorted.map((h) => ({
      company: h.companyName,
      symbol: h.symbol,
      returnValue: `${h.gainPercent >= 0 ? '+' : ''}${h.gainPercent.toFixed(2)}%`,
      isPositive: h.isPositive,
    }));

    return {
      summary,
      performanceLeaders: leaders,
      riskDiversification: {
        diversification: holdings.length >= 5 ? 'Good' : holdings.length >= 2 ? 'Moderate' : 'Low',
        portfolioRisk: 'Moderate',
        sectorExposure: 'Balanced',
      },
    };
  }
}
