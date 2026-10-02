import { Router } from 'express';
import { MarketController } from '../controllers/market.controller';

const router = Router();

router.get('/indices', MarketController.getIndices);
router.get('/sectors', MarketController.getSectors);

export default router;
