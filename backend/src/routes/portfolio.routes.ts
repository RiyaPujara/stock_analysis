import { Router } from 'express';
import { PortfolioController } from '../controllers/portfolio.controller';
import { authenticate } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { addHoldingSchema } from '../validators/portfolio.validator';

const router = Router();

router.use(authenticate as any);

router.get('/', PortfolioController.getSummary as any);
router.get('/summary', PortfolioController.getSummary as any);
router.get('/holdings', PortfolioController.getHoldings as any);
router.post('/holdings', validateBody(addHoldingSchema), PortfolioController.addHolding as any);
router.delete('/holdings/:id', PortfolioController.deleteHolding as any);
router.get('/transactions', PortfolioController.getTransactions as any);
router.get('/analytics', PortfolioController.getAnalytics as any);

export default router;
