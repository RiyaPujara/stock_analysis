import mongoose, { Document, Schema } from 'mongoose';

export interface IWatchlistDocument extends Document {
  userId: mongoose.Types.ObjectId;
  stockId: mongoose.Types.ObjectId;
  symbol: string;
  companyName: string;
  addedAt: Date;
  toFlutterJson(): Record<string, any>;
}

const WatchlistSchema = new Schema<IWatchlistDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    stockId: { type: Schema.Types.ObjectId, ref: 'Stock', required: true, index: true },
    symbol: { type: String, required: true, uppercase: true, trim: true },
    companyName: { type: String, required: true, trim: true },
    addedAt: { type: Date, default: Date.now },
  },
  {
    timestamps: true,
  }
);

WatchlistSchema.index({ userId: 1, stockId: 1 }, { unique: true });

WatchlistSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    stockId: this.stockId.toString(),
    symbol: this.symbol,
    companyName: this.companyName,
    addedAt: this.addedAt.toISOString(),
  };
};

export const Watchlist = mongoose.model<IWatchlistDocument>('Watchlist', WatchlistSchema);
