import { Request, Response, NextFunction } from 'express';
import { MarketService } from '../services/market.service';
import { IndianStockService } from '../services/indianStock.service';
import { GeminiService } from '../services/gemini.service';
import { sendSuccess } from '../utils/response';

export class MarketController {
  static async getIndices(req: Request, res: Response, next: NextFunction) {
    try {
      const indices = await MarketService.getIndices();
      sendSuccess(res, indices, 'Market indices retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getRealtimeIndices(req: Request, res: Response, next: NextFunction) {
    try {
      const indices = await IndianStockService.getRealtimeIndices();
      sendSuccess(res, indices, 'Realtime Indian market indices retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getSectors(req: Request, res: Response, next: NextFunction) {
    try {
      const sectors = await MarketService.getSectors();
      sendSuccess(res, sectors, 'Market sectors retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async searchStocks(req: Request, res: Response, next: NextFunction) {
    try {
      const query = (req.query.search as string) || (req.query.q as string);
      const stocks = await MarketService.searchStocks(query);
      sendSuccess(res, stocks, 'Stocks retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async searchRealtimeStocks(req: Request, res: Response, next: NextFunction) {
    try {
      const query = (req.query.q as string) || (req.query.search as string) || '';
      const stocks = await IndianStockService.searchIndianStocks(query);
      sendSuccess(res, stocks, 'Realtime Indian stocks searched');
    } catch (error) {
      next(error);
    }
  }

  static async getStock(req: Request, res: Response, next: NextFunction) {
    try {
      const stock = await MarketService.getStockBySymbol(req.params.symbol);
      sendSuccess(res, stock, 'Stock details retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getRealtimeStock(req: Request, res: Response, next: NextFunction) {
    try {
      const stock = await IndianStockService.getRealtimeStock(req.params.symbol);
      sendSuccess(res, stock, 'Realtime Indian stock retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getRealtimeBatch(req: Request, res: Response, next: NextFunction) {
    try {
      const symbolsParam = (req.query.symbols as string) || 'RELIANCE,TCS,INFY,HDFCBANK,ICICIBANK';
      const symbols = symbolsParam.split(',').map((s) => s.trim());
      const list = await IndianStockService.getRealtimeBatch(symbols);
      sendSuccess(res, list, 'Realtime Indian stocks batch retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getHistoricalPrices(req: Request, res: Response, next: NextFunction) {
    try {
      const period = (req.query.period as string) || '1D';
      const history = await MarketService.getHistoricalPrices(req.params.symbol, period);
      sendSuccess(res, history, 'Historical prices retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getFundamentals(req: Request, res: Response, next: NextFunction) {
    try {
      const fundamentals = await MarketService.getFundamentals(req.params.symbol);
      sendSuccess(res, fundamentals, 'Fundamentals retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getTechnicals(req: Request, res: Response, next: NextFunction) {
    try {
      const technicals = await MarketService.getTechnicals(req.params.symbol);
      sendSuccess(res, technicals, 'Technicals retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async analyzeWhatIfWithGemini(req: Request, res: Response, next: NextFunction) {
    try {
      const { symbol, companyName, currentPrice, scenario, targetPrice, quantity, timeHorizon, apiKey } = req.body;
      if (!symbol || !scenario) {
        return res.status(400).json({ success: false, message: 'symbol and scenario are required fields' });
      }

      const analysis = await GeminiService.analyzeWhatIfScenario({
        symbol,
        companyName,
        currentPrice: Number(currentPrice) || 1000,
        scenario,
        targetPrice: targetPrice ? Number(targetPrice) : undefined,
        quantity: quantity ? Number(quantity) : undefined,
        timeHorizon,
        apiKey,
      });

      sendSuccess(res, analysis, 'Gemini What-If analysis generated');
    } catch (error) {
      next(error);
    }
  }
}
