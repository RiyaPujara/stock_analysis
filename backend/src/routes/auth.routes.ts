import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { validateBody } from '../middleware/validate';
import { registerSchema, loginSchema, updateProfileSchema, changePasswordSchema } from '../validators/auth.validator';
import { authenticate } from '../middleware/auth';

const router = Router();

router.post('/register', validateBody(registerSchema), AuthController.register);
router.post('/login', validateBody(loginSchema), AuthController.login);

// Current user profile endpoints (supports /me and /profile)
router.get('/me', authenticate as any, AuthController.getProfile as any);
router.get('/profile', authenticate as any, AuthController.getProfile as any);
router.put('/me', authenticate as any, validateBody(updateProfileSchema), AuthController.updateProfile as any);
router.put('/profile', authenticate as any, validateBody(updateProfileSchema), AuthController.updateProfile as any);

// Password modification (supports both POST and PUT)
router.post('/change-password', authenticate as any, validateBody(changePasswordSchema), AuthController.changePassword as any);
router.put('/change-password', authenticate as any, validateBody(changePasswordSchema), AuthController.changePassword as any);

export default router;
