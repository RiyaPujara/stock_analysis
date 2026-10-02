import { Router } from 'express';
import { MarketController } from '../controllers/market.controller';

const router = Router();

router.get('/indices', MarketController.getIndices);
router.get('/indices/realtime', MarketController.getRealtimeIndices);
router.get('/sectors', MarketController.getSectors);
router.post('/what-if', MarketController.analyzeWhatIfWithGemini);

export default router;
