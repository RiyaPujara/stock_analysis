import 'package:flutter/material.dart';
import 'dashboard/dashboard_screens.dart';
import 'market/market_screens.dart';
import 'portfolio/portfolio_screens.dart';
import 'profile/profile_screens.dart';
import 'simulator/what_if_simulator_screen.dart';
import 'notifications/notification_screen.dart';
import 'watchlist/watchlist_screen.dart';
import '../utils/app_theme.dart';
import '../utils/theme_controller.dart';
import '../services/market_service.dart';
import '../models/market_index.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<MarketIndex> _liveIndices = [];

  final List<Widget> _screens = const [
    DashboardScreen(showAppBar: false),
    MarketScreen(showAppBar: false),
    WhatIfSimulatorScreen(showAppBar: false),
    PortfolioScreen(showAppBar: false),
    ProfileScreen(showAppBar: false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveTicker();
  }

  Future<void> _fetchLiveTicker() async {
    try {
      final indices = await MarketService.instance.getIndices();
      if (mounted) {
        setState(() {
          _liveIndices = indices;
        });
      }
    } catch (_) {}
  }

  void _toggleTheme() {
    final current = themeModeNotifier.value;
    if (current == ThemeMode.dark) {
      themeModeNotifier.value = ThemeMode.light;
    } else {
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF090D15) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ==================== PRIMARY TOP NAVBAR ====================
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      // 1. BRAND LOGO & BADGE
                      InkWell(
                        onTap: () => setState(() => _selectedIndex = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: AppTheme.emeraldGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryEmerald.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Stock Pulse',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'AI',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryEmerald,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'LIVE NSE/BSE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryEmerald,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // 2. PROMINENT TOP NAVBAR TABS
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _TopNavTab(
                                icon: Icons.grid_view_rounded,
                                label: 'Home',
                                isSelected: _selectedIndex == 0,
                                onTap: () => setState(() => _selectedIndex = 0),
                              ),
                              const SizedBox(width: 6),
                              _TopNavTab(
                                icon: Icons.candlestick_chart_rounded,
                                label: 'Markets',
                                isSelected: _selectedIndex == 1,
                                badge: 'LIVE',
                                badgeColor: AppTheme.primaryEmerald,
                                onTap: () => setState(() => _selectedIndex = 1),
                              ),
                              const SizedBox(width: 6),
                              _TopNavTab(
                                icon: Icons.auto_awesome_rounded,
                                label: 'AI What-If',
                                isSelected: _selectedIndex == 2,
                                badge: 'GEMINI',
                                isAiTab: true,
                                onTap: () => setState(() => _selectedIndex = 2),
                              ),
                              const SizedBox(width: 6),
                              _TopNavTab(
                                icon: Icons.account_balance_wallet_rounded,
                                label: 'Portfolio',
                                isSelected: _selectedIndex == 3,
                                onTap: () => setState(() => _selectedIndex = 3),
                              ),
                              const SizedBox(width: 6),
                              _TopNavTab(
                                icon: Icons.person_rounded,
                                label: 'Profile',
                                isSelected: _selectedIndex == 4,
                                onTap: () => setState(() => _selectedIndex = 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 3. RIGHT UTILITIES & ACTIONS
                      if (screenWidth > 980 && _liveIndices.isNotEmpty) ...[
                        ..._liveIndices.take(2).map((idx) {
                          final isPos = idx.changePercent >= 0;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  idx.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '₹${idx.currentValue.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${isPos ? '+' : ''}${idx.changePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPos ? AppTheme.successGreen : AppTheme.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // Watchlist Button
                      IconButton(
                        tooltip: 'Watchlist',
                        icon: const Icon(Icons.star_outline_rounded, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WatchlistScreen()),
                          );
                        },
                      ),

                      // Theme Toggle
                      IconButton(
                        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        icon: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          size: 20,
                        ),
                        onPressed: _toggleTheme,
                      ),

                      // Notifications Button
                      IconButton(
                        tooltip: 'Notifications',
                        icon: const Icon(Icons.notifications_none_rounded, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ==================== REAL-TIME TICKER RIBBON ====================
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C101A) : const Color(0xFFF8FAFC),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF161F2E) : const Color(0xFFEEF2F6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MARKET PULSE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryEmerald,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (_liveIndices.isNotEmpty
                                    ? _liveIndices
                                    : [
                                        MarketIndex(name: 'NIFTY 50', symbol: '^NSEI', currentValue: 22421.95, change: -198.45, changePercent: -0.88),
                                        MarketIndex(name: 'SENSEX', symbol: '^BSESN', currentValue: 71909.70, change: -612.30, changePercent: -0.84),
                                        MarketIndex(name: 'BANK NIFTY', symbol: '^NSEBANK', currentValue: 54450.75, change: 240.50, changePercent: 0.44),
                                        MarketIndex(name: 'NIFTY IT', symbol: '^CNXIT', currentValue: 28304.70, change: -115.20, changePercent: -0.40),
                                      ])
                                .map((idx) {
                              final isPos = idx.changePercent >= 0;
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      idx.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '₹${idx.currentValue.toStringAsFixed(1)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isPos ? '+' : ''}${idx.changePercent.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPos ? AppTheme.successGreen : AppTheme.dangerRed,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Text(
                        '0xramm Indian-Stock-Market-API',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C101A) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MobileNavBarItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Home',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _MobileNavBarItem(
                        icon: Icons.candlestick_chart_rounded,
                        label: 'Markets',
                        isSelected: _selectedIndex == 1,
                        hasBadge: true,
                        badgeText: 'LIVE',
                        badgeColor: AppTheme.primaryEmerald,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _MobileAiNavBarItem(
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _MobileNavBarItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Portfolio',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      _MobileNavBarItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isSelected: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// Desktop / Web Top Navbar Tab Widget
class _TopNavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final bool isAiTab;

  const _TopNavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.isAiTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isAiTab) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFFA78BFA),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFFA78BFA),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final activeColor = AppTheme.primaryEmerald;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.16 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : inactiveColor,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.primaryEmerald,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mobile Bottom Nav Bar Item
class _MobileNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasBadge;
  final String? badgeText;
  final Color? badgeColor;

  const _MobileNavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasBadge = false,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.primaryEmerald;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.15 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (hasBadge && badgeText != null)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppTheme.primaryEmerald,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile Bottom Nav Bar AI Tab
class _MobileAiNavBarItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileAiNavBarItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                    const Color(0xFF06B6D4).withValues(alpha: 0.18),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFFA78BFA),
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : const Color(0xFFA78BFA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'What-If',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFFA78BFA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
