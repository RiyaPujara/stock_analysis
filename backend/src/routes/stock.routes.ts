import { Router } from 'express';
import { MarketController } from '../controllers/market.controller';

const router = Router();

router.get('/', MarketController.searchStocks);
router.get('/:symbol', MarketController.getStock);
router.get('/:symbol/history', MarketController.getHistoricalPrices);
router.get('/:symbol/fundamentals', MarketController.getFundamentals);
router.get('/:symbol/technicals', MarketController.getTechnicals);

export default router;
