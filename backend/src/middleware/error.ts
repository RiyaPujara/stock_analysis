import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/response';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction): void => {
  if (err.name === 'ValidationError') {
    sendError(res, err.message, 400, 'VALIDATION_ERROR', err.errors);
    return;
  }

  if (err.code === 11000) {
    sendError(res, 'Duplicate field value entered', 409, 'DUPLICATE_KEY_ERROR', err.keyValue);
    return;
  }

  if (err.name === 'CastError') {
    sendError(res, `Invalid resource identifier: ${err.value}`, 400, 'INVALID_ID');
    return;
  }

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  if (statusCode >= 500) {
    console.error(`[Server Error] ${req.method} ${req.originalUrl}:`, err);
  } else {
    console.warn(`[Client Error ${statusCode}] ${req.method} ${req.originalUrl}: ${message}`);
  }

  sendError(res, message, statusCode, err.code || (statusCode >= 500 ? 'SERVER_ERROR' : 'CLIENT_ERROR'));
};
