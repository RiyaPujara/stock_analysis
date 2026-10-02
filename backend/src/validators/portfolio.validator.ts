import { z } from 'zod';

export const addHoldingSchema = z.object({
  symbol: z.string().min(1, 'Stock symbol is required').toUpperCase(),
  exchange: z.enum(['NSE', 'BSE']).default('NSE'),
  type: z.enum(['BUY', 'SELL']).default('BUY'),
  quantity: z.number().positive('Quantity must be greater than 0'),
  price: z.number().positive('Price must be greater than 0'),
  brokerage: z.number().nonnegative().default(0),
  taxes: z.number().nonnegative().default(0),
});
