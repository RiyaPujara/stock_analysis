import mongoose from 'mongoose';

export const connectDB = async (): Promise<void> => {
  if (mongoose.connection.readyState === 1) {
    return;
  }

  const mongoURI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/stock_analysis';

  try {
    const conn = await mongoose.connect(mongoURI, {
      serverSelectionTimeoutMS: 5000,
      autoIndex: true,
    });
    console.log(`[MongoDB] Connected successfully to: ${conn.connection.host}/${conn.connection.name}`);
  } catch (error) {
    console.error('[MongoDB] Connection error:', error);
    throw error;
  }
};

export const closeDB = async (): Promise<void> => {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.connection.close();
    console.log('[MongoDB] Connection closed.');
  }
};

