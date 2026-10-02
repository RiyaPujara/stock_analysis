import dotenv from 'dotenv';
dotenv.config();

import app from './app';
import { connectDB } from './config/database';
import { AlertService } from './services/alert.service';

const PORT = process.env.PORT || 5001;

const startServer = async () => {
  try {
    await connectDB();

    const server = app.listen(PORT, () => {
      console.log(`[Server] Stock Portfolio & Market Analyzer API running on http://localhost:${PORT}`);
      console.log(`[Server] Health check: http://localhost:${PORT}/health`);
      console.log(`[Server] API v1 base: http://localhost:${PORT}/api/v1`);
    });

    // Start background worker for price alert checks every 60 seconds
    setInterval(async () => {
      try {
        await AlertService.checkAlerts();
      } catch (err) {
        console.error('[AlertWorker] Error checking alerts:', err);
      }
    }, 60000);

    const shutdown = async () => {
      console.log('\n[Server] Shutting down gracefully...');
      server.close(() => {
        console.log('[Server] HTTP server closed.');
        process.exit(0);
      });
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  } catch (error) {
    console.error('[Server] Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
