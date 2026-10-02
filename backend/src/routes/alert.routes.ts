import { Router } from 'express';
import { AlertController } from '../controllers/alert.controller';
import { authenticate } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { createAlertSchema } from '../validators/alert.validator';

const router = Router();

router.use(authenticate as any);

router.get('/', AlertController.getAlerts as any);
router.post('/', validateBody(createAlertSchema), AlertController.createAlert as any);
router.post('/check', AlertController.checkAlerts as any);
router.patch('/:id/toggle', AlertController.toggleAlert as any);
router.delete('/:id', AlertController.deleteAlert as any);

export default router;
