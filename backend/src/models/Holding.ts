import mongoose, { Document, Schema } from 'mongoose';

export interface IHoldingDocument extends Document {
  portfolioId: mongoose.Types.ObjectId;
  stockId: mongoose.Types.ObjectId;
  symbol: string;
  companyName: string;
  quantity: number;
  averageBuyPrice: number;
  createdAt: Date;
  updatedAt: Date;
  toFlutterJson(): Record<string, any>;
}

const HoldingSchema = new Schema<IHoldingDocument>(
  {
    portfolioId: { type: Schema.Types.ObjectId, ref: 'Portfolio', required: true, index: true },
    stockId: { type: Schema.Types.ObjectId, ref: 'Stock', required: true, index: true },
    symbol: { type: String, required: true, uppercase: true, trim: true },
    companyName: { type: String, required: true, trim: true },
    quantity: { type: Number, required: true, min: 0 },
    averageBuyPrice: { type: Number, required: true, min: 0 },
  },
  {
    timestamps: true,
  }
);

HoldingSchema.index({ portfolioId: 1, stockId: 1 }, { unique: true });

HoldingSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    portfolioId: this.portfolioId.toString(),
    stockId: this.stockId.toString(),
    symbol: this.symbol,
    companyName: this.companyName,
    quantity: this.quantity,
    averageBuyPrice: this.averageBuyPrice,
  };
};

export const Holding = mongoose.model<IHoldingDocument>('Holding', HoldingSchema);
