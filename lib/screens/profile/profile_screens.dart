import 'package:flutter/material.dart';

import '../alerts/alerts_screen.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Riya Pujara';
    final userEmail = user?.email ?? 'riya@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            CircleAvatar(
              radius: 45,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // Account
            const _SectionTitle(title: 'Account'),

            _ProfileTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: userName,
              onTap: () {},
            ),

            _ProfileTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: userEmail,
              onTap: () {},
            ),

            _ProfileTile(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: '+91 XXXXX XXXXX',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Preferences
            const _SectionTitle(title: 'Preferences'),

            _ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Recent notifications and updates',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),

            _ProfileTile(
              icon: Icons.add_alert_outlined,
              title: 'Price Alerts',
              subtitle: 'Manage target price triggers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertsScreen(),
                  ),
                );
              },
            ),

            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences and account settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Security
            const _SectionTitle(title: 'Security'),

            _ProfileTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Stock Portfolio & Market Analyzer',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 5),

            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AuthService.instance.logout();
                Navigator.pop(dialogContext);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      onThemeChanged: (isDark) {
                        themeModeNotifier.value =
                            isDark ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}