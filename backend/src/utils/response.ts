import { Response } from 'express';

export const sendSuccess = <T>(res: Response, data: T, message = 'Success', statusCode = 200): Response => {
  return res.status(statusCode).json({
    success: true,
    data,
    message,
    timestamp: new Date().toISOString(),
  });
};

export const sendError = (
  res: Response,
  message: string,
  statusCode = 500,
  code = 'INTERNAL_SERVER_ERROR',
  details: any = null
): Response => {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      ...(details ? { details } : {}),
    },
    timestamp: new Date().toISOString(),
  });
};
