import mongoose, { Document, Schema } from 'mongoose';

export interface IMarketIndexDocument extends Document {
  name: string;
  symbol: string;
  currentValue: number;
  change: number;
  changePercent: number;
  updatedAt: Date;
  toFlutterJson(): Record<string, any>;
}

const MarketIndexSchema = new Schema<IMarketIndexDocument>(
  {
    name: { type: String, required: true, trim: true },
    symbol: { type: String, required: true, unique: true, uppercase: true, trim: true },
    currentValue: { type: Number, required: true },
    change: { type: Number, required: true },
    changePercent: { type: Number, required: true },
  },
  {
    timestamps: true,
  }
);

MarketIndexSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    name: this.name,
    symbol: this.symbol,
    currentValue: this.currentValue,
    change: this.change,
    changePercent: this.changePercent,
  };
};

export const MarketIndex = mongoose.model<IMarketIndexDocument>('MarketIndex', MarketIndexSchema);
