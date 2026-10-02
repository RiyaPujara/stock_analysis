import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUserDocument extends Document {
  name: string;
  email: string;
  phone: string;
  passwordHash: string;
  profileImage?: string;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
  toFlutterJson(): Record<string, any>;
}

const UserSchema = new Schema<IUserDocument>(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true, index: true },
    phone: { type: String, required: true, trim: true },
    passwordHash: { type: String, required: true },
    profileImage: { type: String, default: null },
  },
  {
    timestamps: true,
  }
);

// Method to verify password
UserSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// Method to serialize for Flutter user.dart compatibility
UserSchema.methods.toFlutterJson = function (): Record<string, any> {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    phone: this.phone,
    profileImage: this.profileImage || null,
    createdAt: this.createdAt ? this.createdAt.toISOString() : null,
  };
};

export const User = mongoose.model<IUserDocument>('User', UserSchema);
