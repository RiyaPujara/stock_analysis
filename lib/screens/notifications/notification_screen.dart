import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Price Alert',
      'message': 'Reliance Industries crossed ₹2,900.',
      'time': '10 minutes ago',
      'icon': Icons.trending_up,
      'isRead': false,
    },
    {
      'title': 'Portfolio Update',
      'message': 'Your portfolio gained ₹1,250 today.',
      'time': '1 hour ago',
      'icon': Icons.account_balance_wallet_outlined,
      'isRead': false,
    },
    {
      'title': 'Market Update',
      'message': 'NIFTY 50 is up by 0.72% today.',
      'time': '2 hours ago',
      'icon': Icons.analytics_outlined,
      'isRead': true,
    },
    {
      'title': 'Watchlist Alert',
      'message': 'TCS price changed by +0.82%.',
      'time': '3 hours ago',
      'icon': Icons.star_outline,
      'isRead': true,
    },
    {
      'title': 'Market Opening',
      'message': 'Indian markets opened today at 9:15 AM.',
      'time': 'Yesterday',
      'icon': Icons.notifications_outlined,
      'isRead': true,
    },
  ];

  int get _unreadCount {
    return _notifications.where((notification) {
      return notification['isRead'] == false;
    }).length;
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
      ),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') {
                  _markAllAsRead();
                } else if (value == 'clear') {
                  _clearAll();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'read',
                  child: Text('Mark all as read'),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear all'),
                ),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyNotifications()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _unreadCount == 0
                        ? 'All caught up!'
                        : '$_unreadCount unread notifications',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stay updated with your market and portfolio activity.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    _notifications.length,
                    (index) {
                      final notification = _notifications[index];

                      return _NotificationCard(
                        title: notification['title'],
                        message: notification['message'],
                        time: notification['time'],
                        icon: notification['icon'],
                        isRead: notification['isRead'],
                        onTap: () => _markAsRead(index),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead
          ? null
          : Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 70,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'No Notifications',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are all caught up. New alerts will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}