import mongoose, { Document, Schema } from 'mongoose';
import { AlertCondition } from '../types';

export interface IPriceAlertDocument extends Document {
  userId: mongoose.Types.ObjectId;
  stockId: mongoose.Types.ObjectId;
  symbol: string;
  targetPrice: number;
  condition: AlertCondition;
  isActive: boolean;
  isTriggered: boolean;
  createdAt: Date;
  toFlutterJson(): Record<string, any>;
}

const PriceAlertSchema = new Schema<IPriceAlertDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    stockId: { type: Schema.Types.ObjectId, ref: 'Stock', required: true, index: true },
    symbol: { type: String, required: true, uppercase: true, trim: true },
    targetPrice: { type: Number, required: true, min: 0 },
    condition: { type: String, enum: ['ABOVE', 'BELOW'], required: true },
    isActive: { type: Boolean, default: true, index: true },
    isTriggered: { type: Boolean, default: false, index: true },
  },
  {
    timestamps: true,
  }
);

PriceAlertSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    stockId: this.stockId.toString(),
    symbol: this.symbol,
    targetPrice: this.targetPrice,
    condition: this.condition,
    isActive: this.isActive !== false,
    isTriggered: this.isTriggered,
    createdAt: this.createdAt ? this.createdAt.toISOString() : null,
  };
};

export const PriceAlert = mongoose.model<IPriceAlertDocument>('PriceAlert', PriceAlertSchema);
