import mongoose, { Document, Schema } from 'mongoose';

export interface IStockDocument extends Document {
  symbol: string;
  companyName: string;
  exchange: 'NSE' | 'BSE';
  sector?: string;
  industry?: string;
  description?: string;
  currentPrice: number;
  open: number;
  high: number;
  low: number;
  previousClose: number;
  change: number;
  changePercent: number;
  volume: number;
  week52High?: number;
  week52Low?: number;
  marketCap?: number;
  peRatio?: number;
  eps?: number;
  roe?: number;
  debtToEquity?: number;
  revenueGrowth?: number;
  profitGrowth?: number;
  dividendYield?: number;
  isActive: boolean;
  updatedAt: Date;
  toFlutterJson(): Record<string, any>;
}

const StockSchema = new Schema<IStockDocument>(
  {
    symbol: { type: String, required: true, unique: true, uppercase: true, trim: true, index: true },
    companyName: { type: String, required: true, trim: true, index: true },
    exchange: { type: String, required: true, enum: ['NSE', 'BSE'], default: 'NSE' },
    sector: { type: String, trim: true, index: true },
    industry: { type: String, trim: true },
    description: { type: String, trim: true },
    currentPrice: { type: Number, required: true, default: 0 },
    open: { type: Number, required: true, default: 0 },
    high: { type: Number, required: true, default: 0 },
    low: { type: Number, required: true, default: 0 },
    previousClose: { type: Number, required: true, default: 0 },
    change: { type: Number, required: true, default: 0 },
    changePercent: { type: Number, required: true, default: 0 },
    volume: { type: Number, required: true, default: 0 },
    week52High: { type: Number, default: 0 },
    week52Low: { type: Number, default: 0 },
    marketCap: { type: Number, default: 0 },
    peRatio: { type: Number, default: 0 },
    eps: { type: Number, default: 0 },
    roe: { type: Number, default: 0 },
    debtToEquity: { type: Number, default: 0 },
    revenueGrowth: { type: Number, default: 0 },
    profitGrowth: { type: Number, default: 0 },
    dividendYield: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  {
    timestamps: true,
  }
);

// Search text index for fast autocomplete and search
StockSchema.index({ symbol: 'text', companyName: 'text' });

StockSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    symbol: this.symbol,
    companyName: this.companyName,
    name: this.companyName,
    exchange: this.exchange,
    sector: this.sector || null,
    industry: this.industry || null,
    description: this.description || null,
    currentPrice: this.currentPrice,
    open: this.open,
    high: this.high,
    low: this.low,
    previousClose: this.previousClose,
    change: this.change,
    changePercent: this.changePercent,
    volume: this.volume,
    week52High: this.week52High,
    week52Low: this.week52Low,
    marketCap: this.marketCap,
    peRatio: this.peRatio,
    eps: this.eps,
    dividendYield: this.dividendYield,
    price: `₹${this.currentPrice.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
    isPositive: this.change >= 0,
  };
};

export const Stock = mongoose.model<IStockDocument>('Stock', StockSchema);
