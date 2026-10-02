import { PriceAlert, Stock, Notification } from '../models';
import { AlertCondition } from '../types';

export class AlertService {
  static async getAlerts(userId: string) {
    const alerts = await PriceAlert.find({ userId }).sort({ createdAt: -1 });
    return alerts.map((a) => a.toFlutterJson());
  }

  static async createAlert(userId: string, data: { symbol: string; targetPrice: number; condition: 'ABOVE' | 'BELOW' }) {
    const stock = await Stock.findOne({ symbol: data.symbol.toUpperCase() });
    if (!stock) {
      const error: any = new Error(`Stock ${data.symbol} not found`);
      error.statusCode = 404;
      throw error;
    }

    const alert = await PriceAlert.create({
      userId,
      stockId: stock._id,
      symbol: stock.symbol,
      targetPrice: data.targetPrice,
      condition: data.condition === 'ABOVE' ? AlertCondition.ABOVE : AlertCondition.BELOW,
      isTriggered: false,
    });

    return alert.toFlutterJson();
  }

  static async deleteAlert(userId: string, alertId: string) {
    await PriceAlert.findOneAndDelete({ _id: alertId, userId });
    return { message: 'Alert deleted successfully' };
  }

  static async toggleAlert(userId: string, alertId: string) {
    const alert = await PriceAlert.findOne({ _id: alertId, userId });
    if (!alert) {
      const error: any = new Error('Alert not found');
      error.statusCode = 404;
      throw error;
    }

    alert.isActive = !alert.isActive;
    await alert.save();
    return alert.toFlutterJson();
  }

  static async checkAlerts() {
    const pendingAlerts = await PriceAlert.find({ isTriggered: false, isActive: { $ne: false } });
    const stockIds = [...new Set(pendingAlerts.map((a) => a.stockId.toString()))];
    const stocks = await Stock.find({ _id: { $in: stockIds } });
    const stockMap = new Map(stocks.map((s) => [s._id.toString(), s]));

    let triggeredCount = 0;

    for (const alert of pendingAlerts) {
      const stock = stockMap.get(alert.stockId.toString());
      if (!stock) continue;

      let triggered = false;
      if (alert.condition === AlertCondition.ABOVE && stock.currentPrice >= alert.targetPrice) {
        triggered = true;
      } else if (alert.condition === AlertCondition.BELOW && stock.currentPrice <= alert.targetPrice) {
        triggered = true;
      }

      if (triggered) {
        alert.isTriggered = true;
        await alert.save();
        triggeredCount++;

        // Create user notification
        await Notification.create({
          userId: alert.userId,
          title: 'Price Alert',
          message: `${alert.symbol} ${alert.condition === AlertCondition.ABOVE ? 'crossed above' : 'dropped below'} ₹${alert.targetPrice.toFixed(2)}. Current: ₹${stock.currentPrice.toFixed(2)}`,
          type: 'PRICE_ALERT',
          isRead: false,
        });
      }
    }

    return triggeredCount;
  }
}
