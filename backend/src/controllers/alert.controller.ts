import { Response, NextFunction } from 'express';
import { AlertService } from '../services/alert.service';
import { sendSuccess } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export class AlertController {
  static async getAlerts(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const alerts = await AlertService.getAlerts(req.user!._id.toString());
      sendSuccess(res, alerts, 'Alerts retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async createAlert(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const alert = await AlertService.createAlert(req.user!._id.toString(), req.body);
      sendSuccess(res, alert, 'Alert created', 201);
    } catch (error) {
      next(error);
    }
  }

  static async toggleAlert(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const alert = await AlertService.toggleAlert(req.user!._id.toString(), req.params.id);
      sendSuccess(res, alert, 'Alert status updated');
    } catch (error) {
      next(error);
    }
  }

  static async deleteAlert(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await AlertService.deleteAlert(req.user!._id.toString(), req.params.id);
      sendSuccess(res, result, 'Alert deleted');
    } catch (error) {
      next(error);
    }
  }

  static async checkAlerts(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const triggeredCount = await AlertService.checkAlerts();
      sendSuccess(res, { triggeredCount }, 'Alert evaluation completed');
    } catch (error) {
      next(error);
    }
  }
}
