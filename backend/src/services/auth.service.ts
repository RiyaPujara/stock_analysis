import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User, Portfolio, Notification, IUserDocument } from '../models';

export class AuthService {
  private static generateToken(user: IUserDocument): string {
    const secret = process.env.JWT_SECRET || 'super_secret_jwt_key_stock_analysis_2026_dev';
    const expiresIn = process.env.JWT_EXPIRES_IN || '7d';

    return jwt.sign(
      {
        userId: user._id.toString(),
        email: user.email,
      },
      secret,
      { expiresIn: (expiresIn as any) }
    );
  }

  static async register(data: { name: string; email: string; phone: string; password: string }) {
    const existing = await User.findOne({ email: data.email.toLowerCase() });
    if (existing) {
      const error: any = new Error('Email is already registered');
      error.statusCode = 409;
      error.code = 'USER_ALREADY_EXISTS';
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const user = await User.create({
      name: data.name,
      email: data.email.toLowerCase(),
      phone: data.phone,
      passwordHash,
    });

    // Automatically create a default portfolio for the new user
    await Portfolio.create({
      userId: user._id,
      name: 'Primary Portfolio',
      description: 'Default portfolio for stock tracking',
    });

    // Create a welcome notification
    await Notification.create({
      userId: user._id,
      title: 'Welcome to Stock Analyzer',
      message: 'Your account and primary portfolio have been created successfully.',
      type: 'MARKET_UPDATE',
      isRead: false,
    });

    const token = this.generateToken(user);

    return {
      token,
      user: user.toFlutterJson(),
    };
  }

  static async login(email: string, password: string) {
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      const error: any = new Error('Invalid email or password');
      error.statusCode = 401;
      error.code = 'INVALID_CREDENTIALS';
      throw error;
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      const error: any = new Error('Invalid email or password');
      error.statusCode = 401;
      error.code = 'INVALID_CREDENTIALS';
      throw error;
    }

    const token = this.generateToken(user);

    return {
      token,
      user: user.toFlutterJson(),
    };
  }

  static async getProfile(userId: string) {
    const user = await User.findById(userId);
    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }
    return user.toFlutterJson();
  }

  static async updateProfile(userId: string, data: { name?: string; phone?: string; profileImage?: string | null }) {
    const user = await User.findById(userId);
    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    if (data.name) user.name = data.name;
    if (data.phone) user.phone = data.phone;
    if (data.profileImage !== undefined) user.profileImage = data.profileImage || undefined;

    await user.save();
    return user.toFlutterJson();
  }

  static async changePassword(userId: string, currentPassword: string, newPassword: string) {
    const user = await User.findById(userId);
    if (!user) {
      const error: any = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      const error: any = new Error('Current password is incorrect');
      error.statusCode = 400;
      error.code = 'INCORRECT_PASSWORD';
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    await user.save();

    return { message: 'Password changed successfully' };
  }
}
