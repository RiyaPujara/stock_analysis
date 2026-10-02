import mongoose, { Document, Schema } from 'mongoose';

export interface INotificationDocument extends Document {
  userId: mongoose.Types.ObjectId;
  title: string;
  message: string;
  type: string;
  isRead: boolean;
  createdAt: Date;
  toFlutterJson(): Record<string, any>;
}

const NotificationSchema = new Schema<INotificationDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true },
    message: { type: String, required: true, trim: true },
    type: { type: String, default: 'MARKET_UPDATE' },
    isRead: { type: Boolean, default: false, index: true },
  },
  {
    timestamps: true,
  }
);

NotificationSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    userId: this.userId.toString(),
    title: this.title,
    message: this.message,
    type: this.type,
    isRead: this.isRead,
    createdAt: this.createdAt ? this.createdAt.toISOString() : null,
  };
};

export const Notification = mongoose.model<INotificationDocument>('Notification', NotificationSchema);
