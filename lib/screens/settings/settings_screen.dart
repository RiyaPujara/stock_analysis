import 'package:flutter/material.dart';

import '../../utils/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _priceAlertsEnabled = true;

  bool get _darkModeEnabled =>
      themeModeNotifier.value == ThemeMode.dark;

  void _setTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;

    setState(() {});

    Navigator.pop(context);
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme = themeModeNotifier.value;

        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.brightness_auto_outlined,
                ),
                title: const Text('System Default'),
                trailing: currentTheme == ThemeMode.system
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _setTheme(ThemeMode.system);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.light_mode_outlined,
                ),
                title: const Text('Light'),
                trailing: currentTheme == ThemeMode.light
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _setTheme(ThemeMode.light);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.dark_mode_outlined,
                ),
                title: const Text('Dark'),
                trailing: currentTheme == ThemeMode.dark
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _setTheme(ThemeMode.dark);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Stock Analyzer',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2026 Stock Portfolio & Market Analyzer',
      children: const [
        SizedBox(height: 16),
        Text(
          'A mobile application for tracking portfolios, '
          'monitoring Indian stocks and analyzing market data.',
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionTitle(title: 'Account'),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: 'Manage your profile information',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'riya@example.com',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: '+91 98765 43210',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'Notifications'),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_outlined,
                  ),
                  title: const Text('Notifications'),
                  subtitle: const Text(
                    'Receive app notifications',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.price_change_outlined,
                  ),
                  title: const Text('Price Alerts'),
                  subtitle: const Text(
                    'Get notified about stock price changes',
                  ),
                  value: _priceAlertsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _priceAlertsEnabled = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'Appearance'),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _darkModeEnabled
                      ? 'Dark mode'
                      : themeModeNotifier.value ==
                              ThemeMode.system
                          ? 'System default'
                          : 'Light mode',
                  onTap: _showThemeDialog,
                ),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text(
                    'Use dark appearance',
                  ),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    themeModeNotifier.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light;

                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'Security'),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  subtitle: 'Manage account security',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle(title: 'About'),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Stock Analyzer',
                  subtitle: 'Version 1.0.0',
                  onTap: _showAboutDialog,
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms of service',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Learn how your data is handled',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              'Stock Portfolio & Market Analyzer',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}