import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { sendSuccess } from '../utils/response';
import { AuthRequest } from '../middleware/auth';

export class AuthController {
  static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.register(req.body);
      sendSuccess(res, result, 'User registered successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password);
      sendSuccess(res, result, 'Login successful');
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await AuthService.getProfile(req.user!._id.toString());
      sendSuccess(res, user, 'Profile retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const updated = await AuthService.updateProfile(req.user!._id.toString(), req.body);
      sendSuccess(res, updated, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async changePassword(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { currentPassword, newPassword } = req.body;
      const result = await AuthService.changePassword(req.user!._id.toString(), currentPassword, newPassword);
      sendSuccess(res, result, 'Password updated successfully');
    } catch (error) {
      next(error);
    }
  }
}
