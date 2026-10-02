import { Response, NextFunction } from 'express';
import { WatchlistService } from '../services/watchlist.service';
import { sendSuccess } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export class WatchlistController {
  static async getWatchlist(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const items = await WatchlistService.getWatchlist(req.user!._id.toString());
      sendSuccess(res, items, 'Watchlist retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async addToWatchlist(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const item = await WatchlistService.addToWatchlist(req.user!._id.toString(), req.body.symbol);
      sendSuccess(res, item, 'Added to watchlist', 201);
    } catch (error) {
      next(error);
    }
  }

  static async removeFromWatchlist(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const identifier = req.params.symbolOrId || req.params.stockId;
      const result = await WatchlistService.removeFromWatchlist(req.user!._id.toString(), identifier);
      sendSuccess(res, result, 'Removed from watchlist');
    } catch (error) {
      next(error);
    }
  }
}
