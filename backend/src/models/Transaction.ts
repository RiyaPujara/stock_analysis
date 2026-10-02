import mongoose, { Document, Schema } from 'mongoose';
import { TransactionType } from '../types';

export interface ITransactionDocument extends Document {
  portfolioId: mongoose.Types.ObjectId;
  stockId: mongoose.Types.ObjectId;
  symbol: string;
  type: TransactionType;
  quantity: number;
  price: number;
  brokerage: number;
  taxes: number;
  totalAmount: number;
  transactionDate: Date;
  toFlutterJson(): Record<string, any>;
}

const TransactionSchema = new Schema<ITransactionDocument>(
  {
    portfolioId: { type: Schema.Types.ObjectId, ref: 'Portfolio', required: true, index: true },
    stockId: { type: Schema.Types.ObjectId, ref: 'Stock', required: true, index: true },
    symbol: { type: String, required: true, uppercase: true, trim: true },
    type: { type: String, enum: ['BUY', 'SELL'], required: true },
    quantity: { type: Number, required: true, min: 0.0001 },
    price: { type: Number, required: true, min: 0 },
    brokerage: { type: Number, default: 0 },
    taxes: { type: Number, default: 0 },
    totalAmount: { type: Number, required: true },
    transactionDate: { type: Date, default: Date.now, index: true },
  },
  {
    timestamps: true,
  }
);

TransactionSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    portfolioId: this.portfolioId.toString(),
    stockId: this.stockId.toString(),
    symbol: this.symbol,
    type: this.type,
    quantity: this.quantity,
    price: this.price,
    brokerage: this.brokerage,
    taxes: this.taxes,
    totalAmount: this.totalAmount,
    transactionDate: this.transactionDate.toISOString(),
  };
};

export const Transaction = mongoose.model<ITransactionDocument>('Transaction', TransactionSchema);
