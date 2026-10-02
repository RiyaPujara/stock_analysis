import { Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service';
import { sendSuccess } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export class NotificationController {
  static async getNotifications(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const notifications = await NotificationService.getNotifications(req.user!._id.toString());
      sendSuccess(res, notifications, 'Notifications retrieved');
    } catch (error) {
      next(error);
    }
  }

  static async markAsRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const updated = await NotificationService.markAsRead(req.user!._id.toString(), req.params.id);
      sendSuccess(res, updated, 'Notification marked as read');
    } catch (error) {
      next(error);
    }
  }

  static async markAllAsRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await NotificationService.markAllAsRead(req.user!._id.toString());
      sendSuccess(res, result, 'All notifications marked as read');
    } catch (error) {
      next(error);
    }
  }

  static async deleteNotification(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await NotificationService.deleteNotification(req.user!._id.toString(), req.params.id);
      sendSuccess(res, result, 'Notification deleted');
    } catch (error) {
      next(error);
    }
  }

  static async clearAll(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await NotificationService.clearAll(req.user!._id.toString());
      sendSuccess(res, result, 'All notifications cleared');
    } catch (error) {
      next(error);
    }
  }
}
