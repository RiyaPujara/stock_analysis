export interface IUser {
  _id: string;
  name: string;
  email: string;
  phone: string;
  passwordHash: string;
  profileImage?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IStock {
  _id: string;
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
  dividendYield?: number;
  isActive: boolean;
  updatedAt: Date;
}

export interface IPortfolio {
  _id: string;
  userId: string;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IHolding {
  _id: string;
  portfolioId: string;
  stockId: string;
  symbol: string;
  companyName?: string;
  quantity: number;
  averageBuyPrice: number;
  createdAt: Date;
  updatedAt: Date;
}

export enum TransactionType {
  BUY = 'BUY',
  SELL = 'SELL',
}

export interface ITransaction {
  _id: string;
  portfolioId: string;
  stockId: string;
  symbol: string;
  type: TransactionType;
  quantity: number;
  price: number;
  brokerage: number;
  taxes: number;
  totalAmount: number;
  transactionDate: Date;
}

export interface IWatchlistItem {
  _id: string;
  userId: string;
  stockId: string;
  symbol: string;
  companyName: string;
  addedAt: Date;
}

export enum AlertCondition {
  ABOVE = 'ABOVE',
  BELOW = 'BELOW',
}

export interface IPriceAlert {
  _id: string;
  userId: string;
  stockId: string;
  symbol: string;
  targetPrice: number;
  condition: AlertCondition;
  isActive: boolean;
  isTriggered: boolean;
  createdAt: Date;
}

export interface INotification {
  _id: string;
  userId: string;
  title: string;
  message: string;
  type: 'PRICE_ALERT' | 'PORTFOLIO_UPDATE' | 'MARKET_UPDATE';
  isRead: boolean;
  createdAt: Date;
}

export interface IHistoricalPrice {
  symbol: string;
  date: Date;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

export interface IMarketIndex {
  name: string;
  symbol: string;
  currentValue: number;
  change: number;
  changePercent: number;
  updatedAt: Date;
}

export interface IApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  message?: string;
  timestamp: string;
}
