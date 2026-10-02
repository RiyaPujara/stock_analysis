import mongoose, { Document, Schema } from 'mongoose';

export interface IHistoricalPriceDocument extends Document {
  symbol: string;
  date: Date;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  toFlutterJson(): Record<string, any>;
}

const HistoricalPriceSchema = new Schema<IHistoricalPriceDocument>(
  {
    symbol: { type: String, required: true, uppercase: true, trim: true, index: true },
    date: { type: Date, required: true, index: true },
    open: { type: Number, required: true },
    high: { type: Number, required: true },
    low: { type: Number, required: true },
    close: { type: Number, required: true },
    volume: { type: Number, required: true },
  },
  {
    timestamps: false,
  }
);

HistoricalPriceSchema.index({ symbol: 1, date: -1 });

HistoricalPriceSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    date: this.date.toISOString(),
    open: this.open,
    high: this.high,
    low: this.low,
    close: this.close,
    volume: this.volume,
  };
};

export const HistoricalPrice = mongoose.model<IHistoricalPriceDocument>('HistoricalPrice', HistoricalPriceSchema);
