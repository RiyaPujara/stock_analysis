import { Router } from 'express';
import { MarketController } from '../controllers/market.controller';

const router = Router();

// Real-time Indian Stock Market API routes (must come before parameterized :symbol)
router.get('/realtime/search', MarketController.searchRealtimeStocks);
router.get('/realtime/batch', MarketController.getRealtimeBatch);
router.get('/realtime/:symbol', MarketController.getRealtimeStock);

// Standard / DB cached routes
router.get('/', MarketController.searchStocks);
router.get('/:symbol', MarketController.getStock);
router.get('/:symbol/history', MarketController.getHistoricalPrices);
router.get('/:symbol/fundamentals', MarketController.getFundamentals);
router.get('/:symbol/technicals', MarketController.getTechnicals);

export default router;
