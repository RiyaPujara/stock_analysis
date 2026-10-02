import { Notification } from '../models';

export class NotificationService {
  static async getNotifications(userId: string) {
    const notifications = await Notification.find({ userId }).sort({ createdAt: -1 });

    return notifications.map((n) => {
      const diffMs = Date.now() - n.createdAt.getTime();
      const diffMins = Math.floor(diffMs / (60 * 1000));
      const diffHours = Math.floor(diffMins / 60);
      const diffDays = Math.floor(diffHours / 24);

      let timeAgo = 'Just now';
      if (diffMins < 60) timeAgo = `${diffMins || 1} minute${diffMins === 1 ? '' : 's'} ago`;
      else if (diffHours < 24) timeAgo = `${diffHours} hour${diffHours === 1 ? '' : 's'} ago`;
      else timeAgo = `${diffDays} day${diffDays === 1 ? '' : 's'} ago`;

      return {
        id: n._id.toString(),
        userId: n.userId.toString(),
        title: n.title,
        message: n.message,
        type: n.type,
        time: timeAgo,
        isRead: n.isRead,
        createdAt: n.createdAt.toISOString(),
      };
    });
  }

  static async markAsRead(userId: string, notificationId: string) {
    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId },
      { isRead: true },
      { new: true }
    );
    if (!notification) {
      const error: any = new Error('Notification not found');
      error.statusCode = 404;
      throw error;
    }
    return notification.toFlutterJson();
  }

  static async markAllAsRead(userId: string) {
    await Notification.updateMany({ userId, isRead: false }, { isRead: true });
    return { message: 'All notifications marked as read' };
  }

  static async deleteNotification(userId: string, notificationId: string) {
    const deleted = await Notification.findOneAndDelete({ _id: notificationId, userId });
    if (!deleted) {
      const error: any = new Error('Notification not found');
      error.statusCode = 404;
      throw error;
    }
    return { message: 'Notification deleted successfully' };
  }

  static async clearAll(userId: string) {
    await Notification.deleteMany({ userId });
    return { message: 'All notifications cleared' };
  }
}
