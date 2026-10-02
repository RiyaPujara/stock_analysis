import 'package:flutter/material.dart';
import 'api_client.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final List data = await _api.get('/notifications');
      return data.map((e) {
        final map = Map<String, dynamic>.from(e);
        IconData icon = Icons.notifications_outlined;
        if (map['type'] == 'PRICE_ALERT') {
          icon = Icons.trending_up;
        } else if (map['type'] == 'PORTFOLIO_UPDATE') {
          icon = Icons.account_balance_wallet_outlined;
        } else if (map['type'] == 'MARKET_UPDATE') {
          icon = Icons.analytics_outlined;
        }
        map['icon'] = icon;
        return map;
      }).toList();
    } catch (_) {
      return [
        {
          'id': '1',
          'title': 'Price Alert',
          'message': 'Reliance Industries crossed ₹2,900.',
          'time': '10 minutes ago',
          'icon': Icons.trending_up,
          'isRead': false,
        },
        {
          'id': '2',
          'title': 'Portfolio Update',
          'message': 'Your portfolio gained ₹1,250 today.',
          'time': '1 hour ago',
          'icon': Icons.account_balance_wallet_outlined,
          'isRead': false,
        },
        {
          'id': '3',
          'title': 'Market Update',
          'message': 'NIFTY 50 is up by 0.72% today.',
          'time': '2 hours ago',
          'icon': Icons.analytics_outlined,
          'isRead': true,
        },
      ];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.patch('/notifications/$id/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post('/notifications/mark-all-read');
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _api.delete('/notifications');
    } catch (_) {}
  }
}
