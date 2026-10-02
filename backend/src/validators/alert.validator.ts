import { z } from 'zod';

export const createAlertSchema = z.object({
  symbol: z.string().min(1, 'Stock symbol is required').toUpperCase(),
  targetPrice: z.number().positive('Target price must be greater than 0'),
  condition: z.enum(['ABOVE', 'BELOW']),
});
