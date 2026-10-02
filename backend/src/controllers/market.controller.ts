import { Request, Response, NextFunction } from 'express';
import { MarketService } from '../services/market.service';
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
      const query = req.query.search as string;
      const stocks = await MarketService.searchStocks(query);
      sendSuccess(res, stocks, 'Stocks retrieved');
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
}
