import 'package:flutter/material.dart';

import '../analytics/analytics_screen.dart';
import '../market/market_screens.dart';
import '../notifications/notification_screen.dart';
import '../portfolio/portfolio_details_screen.dart';
import '../portfolio/portfolio_screens.dart';
import '../simulator/what_if_simulator_screen.dart';
import '../stock/stock_details_screen.dart';
import '../watchlist/watchlist_screen.dart';
import '../../services/portfolio_service.dart';
import '../../services/market_service.dart';
import '../../services/watchlist_service.dart';
import '../../models/market_index.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;
  List<MarketIndex> _indices = [];
  List<Map<String, dynamic>> _watchlist = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await PortfolioService.instance.getSummary();
    final indices = await MarketService.instance.getIndices();
    final watchlist = await WatchlistService.instance.getWatchlist();

    if (mounted) {
      setState(() {
        _summary = summary;
        _indices = indices;
        _watchlist = watchlist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = (_summary?['totalValue'] ?? 125000.0) as num;
    final todayGain = (_summary?['todayGain'] ?? 2450.0) as num;
    final todayGainPercent = (_summary?['todayGainPercent'] ?? 1.98) as num;
    final isPositiveGain = todayGain >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening 👋',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Portfolio Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          isPositiveGain ? Icons.trending_up : Icons.trending_down,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isPositiveGain ? '+' : ''}₹${todayGain.abs().toStringAsFixed(2)} (${isPositiveGain ? '+' : ''}${todayGainPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PortfolioDetailsScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Text('View Portfolio Details'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Portfolio',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PortfolioScreen(),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.analytics_outlined,
                      title: 'Market',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bar_chart_outlined,
                      title: 'Analytics',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.auto_awesome,
                      title: 'What-If',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WhatIfSimulatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: _QuickActionCard(
                  icon: Icons.star_outline,
                  title: 'Watchlist',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WatchlistScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Watchlist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Watchlist',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WatchlistScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_watchlist.isNotEmpty)
                ..._watchlist.take(3).map((item) {
                  final chg = ((item['changePercent'] ?? 0.0) as num).toDouble();
                  final isPos = chg >= 0;
                  final price = ((item['currentPrice'] ?? 0.0) as num).toDouble();
                  final name = item['name'] ?? item['companyName'] ?? item['symbol'] ?? 'Stock';
                  final sym = item['symbol'] ?? '';

                  return _StockCard(
                    companyName: name,
                    symbol: sym,
                    price: '₹${price.toStringAsFixed(2)}',
                    change: '${isPos ? '+' : ''}${chg.toStringAsFixed(2)}%',
                    isPositive: isPos,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailsScreen(
                            companyName: name,
                            symbol: sym,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                  );
                })
              else ...[
                _StockCard(
                  companyName: 'Reliance Industries',
                  symbol: 'RELIANCE',
                  price: '₹2,945.50',
                  change: '+1.25%',
                  isPositive: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockDetailsScreen(
                          companyName: 'Reliance Industries',
                          symbol: 'RELIANCE',
                        ),
                      ),
                    );
                  },
                ),
                _StockCard(
                  companyName: 'Tata Consultancy Services',
                  symbol: 'TCS',
                  price: '₹4,125.80',
                  change: '+0.82%',
                  isPositive: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockDetailsScreen(
                          companyName: 'Tata Consultancy Services',
                          symbol: 'TCS',
                        ),
                      ),
                    );
                  },
                ),
                _StockCard(
                  companyName: 'Infosys',
                  symbol: 'INFY',
                  price: '₹1,485.20',
                  change: '-0.45%',
                  isPositive: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockDetailsScreen(
                          companyName: 'Infosys',
                          symbol: 'INFY',
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 28),

              // Market Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarketScreen(),
                        ),
                      );
                    },
                    child: const Text('View Market'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _MarketCard(
                      title: _indices.isNotEmpty ? _indices[0].name : 'NIFTY 50',
                      value: _indices.isNotEmpty
                          ? _indices[0].value.toStringAsFixed(2)
                          : '25,350.20',
                      change: _indices.isNotEmpty
                          ? '${_indices[0].changePercent >= 0 ? '+' : ''}${_indices[0].changePercent.toStringAsFixed(2)}%'
                          : '+0.72%',
                      isPositive: _indices.isNotEmpty
                          ? _indices[0].changePercent >= 0
                          : true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MarketCard(
                      title: _indices.length > 1 ? _indices[1].name : 'SENSEX',
                      value: _indices.length > 1
                          ? _indices[1].value.toStringAsFixed(2)
                          : '82,450.30',
                      change: _indices.length > 1
                          ? '${_indices[1].changePercent >= 0 ? '+' : ''}${_indices[1].changePercent.toStringAsFixed(2)}%'
                          : '+0.58%',
                      isPositive: _indices.length > 1
                          ? _indices[1].changePercent >= 0
                          : true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final String companyName;
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;
  final VoidCallback onTap;

  const _StockCard({
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      symbol,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    change,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final VoidCallback onTap;

  const _MarketCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    isPositive
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
