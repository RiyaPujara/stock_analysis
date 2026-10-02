import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import mongoose from 'mongoose';
import routes from './routes';
import { errorHandler } from './middleware/error';
import { sendSuccess, sendError } from './utils/response';

const app = express();

// Security and utility middleware
app.use(helmet());
app.use(cors({ origin: '*' }));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// Health Check
app.get('/health', (req: Request, res: Response) => {
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  sendSuccess(
    res,
    {
      status: 'healthy',
      database: dbStatus,
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
    },
    'Backend is running'
  );
});

// Main API V1 Router
app.use('/api/v1', routes);

// 404 Catch-All Handler
app.use((req: Request, res: Response) => {
  sendError(res, `Endpoint ${req.method} ${req.originalUrl} not found`, 404, 'NOT_FOUND');
});

// Centralized Error Handler
app.use(errorHandler);

export default app;
