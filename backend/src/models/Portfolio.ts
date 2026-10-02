import mongoose, { Document, Schema } from 'mongoose';

export interface IPortfolioDocument extends Document {
  userId: mongoose.Types.ObjectId;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
  toFlutterJson(): Record<string, any>;
}

const PortfolioSchema = new Schema<IPortfolioDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    name: { type: String, required: true, default: 'My Portfolio', trim: true },
    description: { type: String, trim: true },
  },
  {
    timestamps: true,
  }
);

PortfolioSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    name: this.name,
    description: this.description || null,
    createdAt: this.createdAt ? this.createdAt.toISOString() : null,
  };
};

export const Portfolio = mongoose.model<IPortfolioDocument>('Portfolio', PortfolioSchema);
