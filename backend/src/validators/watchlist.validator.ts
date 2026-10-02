import { z } from 'zod';

export const addToWatchlistSchema = z.object({
  symbol: z.string().min(1, 'Stock symbol is required').toUpperCase(),
});
