import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User, IUserDocument } from '../models';
import { sendError } from '../utils/response';

export interface AuthRequest extends Request {
  user?: IUserDocument;
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    sendError(res, 'Authentication token missing or invalid', 401, 'UNAUTHORIZED');
    return;
  }

  const token = authHeader.split(' ')[1];
  const jwtSecret = process.env.JWT_SECRET || 'super_secret_jwt_key_stock_analysis_2026_dev';

  try {
    const decoded = jwt.verify(token, jwtSecret) as { userId: string; email: string };
    const user = await User.findById(decoded.userId);

    if (!user) {
      sendError(res, 'User no longer exists', 401, 'UNAUTHORIZED');
      return;
    }

    req.user = user;
    next();
  } catch (error: any) {
    sendError(res, 'Invalid or expired authentication token', 401, 'TOKEN_EXPIRED');
  }
};
