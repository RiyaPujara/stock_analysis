import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

router.use(authenticate as any);

router.get('/', NotificationController.getNotifications as any);
router.patch('/:id/read', NotificationController.markAsRead as any);
router.post('/mark-all-read', NotificationController.markAllAsRead as any);
router.delete('/', NotificationController.clearAll as any);
router.delete('/:id', NotificationController.deleteNotification as any);

export default router;
