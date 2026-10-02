import { Response, NextFunction } from 'express';
import { PortfolioService } from '../services/portfolio.service';
import { sendSuccess } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export class PortfolioController {
  static async getSummary(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const summary = await PortfolioService.getPortfolioSummary(req.user!._id.toString());
      sendSuccess(res, summary, 'Portfolio summary retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getHoldings(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const holdings = await PortfolioService.getHoldings(req.user!._id.toString());
      sendSuccess(res, holdings, 'Holdings retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async addHolding(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await PortfolioService.addTransaction(req.user!._id.toString(), req.body);
      sendSuccess(res, result, 'Holding transaction recorded', 201);
    } catch (error) {
      next(error);
    }
  }

  static async deleteHolding(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await PortfolioService.deleteHolding(req.user!._id.toString(), req.params.id);
      sendSuccess(res, result, 'Holding removed successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getTransactions(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const transactions = await PortfolioService.getTransactions(req.user!._id.toString());
      sendSuccess(res, transactions, 'Transactions retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async getAnalytics(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const analytics = await PortfolioService.getAnalytics(req.user!._id.toString());
      sendSuccess(res, analytics, 'Analytics retrieved');
    } catch (error) {
      next(error);
    }
  }
}
