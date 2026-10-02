import { Router } from 'express';
import { WatchlistController } from '../controllers/watchlist.controller';
import { authenticate } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { addToWatchlistSchema } from '../validators/watchlist.validator';

const router = Router();

router.use(authenticate as any);

router.get('/', WatchlistController.getWatchlist as any);
router.post('/', validateBody(addToWatchlistSchema), WatchlistController.addToWatchlist as any);
router.delete('/:symbolOrId', WatchlistController.removeFromWatchlist as any);

export default router;
