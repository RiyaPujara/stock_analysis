import { Router } from 'express';
import authRoutes from './auth.routes';
import marketRoutes from './market.routes';
import stockRoutes from './stock.routes';
import portfolioRoutes from './portfolio.routes';
import watchlistRoutes from './watchlist.routes';
import alertRoutes from './alert.routes';
import notificationRoutes from './notification.routes';
import { MarketController } from '../controllers/market.controller';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', authRoutes);
router.use('/market', marketRoutes);
router.use('/stocks', stockRoutes);
router.use('/portfolio', portfolioRoutes);
router.use('/watchlist', watchlistRoutes);
router.use('/alerts', alertRoutes);
router.use('/notifications', notificationRoutes);

// Direct AI routes for What-If scenario simulations
router.post('/ai/what-if', MarketController.analyzeWhatIfWithGemini);
router.post('/simulator/what-if', MarketController.analyzeWhatIfWithGemini);

export default router;
