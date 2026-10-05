import 'package:flutter/material.dart';

import '../stock/stock_details_screen.dart';
import 'add_holding_screen.dart';
import 'portfolio_details_screen.dart';
import '../../services/portfolio_service.dart';
import '../../models/holding.dart';
import '../../utils/app_theme.dart';

class PortfolioScreen extends StatefulWidget {
  final bool showAppBar;
  const PortfolioScreen({super.key, this.showAppBar = false});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, dynamic>? _summary;
  List<Holding> _holdings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final summary = await PortfolioService.instance.getSummary();
    final holdings = await PortfolioService.instance.getHoldings();

    if (mounted) {
      setState(() {
        _summary = summary;
        _holdings = holdings;
        _isLoading = false;
      });
    }
  }

  void _openAddHolding(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHoldingScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _openPortfolioDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PortfolioDetailsScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _openStockDetails(
    BuildContext context, {
    required String companyName,
    required String symbol,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailsScreen(
          companyName: companyName,
          symbol: symbol,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalValue = (_summary?['totalValue'] ?? 125000.0) as num;
    final totalGainLoss = (_summary?['totalGainLoss'] ?? 12450.0) as num;
    final totalGainLossPercent =
        (_summary?['totalGainLossPercent'] ?? 11.05) as num;
    final isOverallPositive = totalGainLoss >= 0;

    final todayGain = (_summary?['todayGain'] ?? 2450.0) as num;
    final todayGainPercent = (_summary?['todayGainPercent'] ?? 1.98) as num;
    final isTodayPositive = todayGain >= 0;

    final invested = (_summary?['totalInvested'] ?? 112550.0) as num;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('My Portfolio'),
              actions: [
                IconButton(
                  onPressed: () => _openAddHolding(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Holding',
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portfolio Summary Card - Modern Futuristic Aesthetic
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Portfolio Value',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, size: 12, color: AppTheme.primaryEmerald),
                              SizedBox(width: 4),
                              Text(
                                'LIVE SYNC',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryEmerald,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹${totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isOverallPositive ? AppTheme.successGreen : AppTheme.dangerRed)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverallPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: isOverallPositive ? AppTheme.successGreen : AppTheme.dangerRed,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isOverallPositive ? '+' : ''}₹${totalGainLoss.abs().toStringAsFixed(2)} (${isOverallPositive ? '+' : ''}${totalGainLossPercent.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: isOverallPositive ? AppTheme.successGreen : AppTheme.dangerRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Overall Returns',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _openPortfolioDetails(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'View Portfolio Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Performance
              Text(
                "Today's Performance",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _PerformanceCard(
                      title: "Today's Gain",
                      value:
                          '${isTodayPositive ? '+' : ''}₹${todayGain.abs().toStringAsFixed(2)}',
                      percentage:
                          '${isTodayPositive ? '+' : ''}${todayGainPercent.toStringAsFixed(2)}%',
                      isPositive: isTodayPositive,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PerformanceCard(
                      title: 'Invested',
                      value: '₹${invested.toStringAsFixed(2)}',
                      percentage: '',
                      isPositive: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Asset Allocation
              Text(
                'Asset Allocation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _AllocationRow(
                        name: 'Stocks',
                        percentage: totalValue > 0 ? '90%' : '0%',
                        value: '₹${totalValue.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      const _AllocationRow(
                        name: 'Cash',
                        percentage: '10%',
                        value: '₹10,000.00',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Holdings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Holdings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => _openPortfolioDetails(context),
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_holdings.isNotEmpty)
                ..._holdings.map((h) {
                  final isPos = h.gainLoss >= 0;
                  return _HoldingCard(
                    companyName: h.stockName.isNotEmpty ? h.stockName : h.stockSymbol,
                    symbol: h.stockSymbol,
                    quantity: '${h.quantity} shares',
                    value: '₹${h.totalValue.toStringAsFixed(2)}',
                    gain: '${isPos ? '+' : ''}₹${h.gainLoss.abs().toStringAsFixed(2)}',
                    isPositive: isPos,
                    onTap: () => _openStockDetails(
                      context,
                      companyName:
                          h.stockName.isNotEmpty ? h.stockName : h.stockSymbol,
                      symbol: h.stockSymbol,
                    ),
                  );
                })
              else if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                _HoldingCard(
                  companyName: 'Reliance Industries',
                  symbol: 'RELIANCE',
                  quantity: '10 shares',
                  value: '₹29,455',
                  gain: '+₹1,250',
                  isPositive: true,
                  onTap: () => _openStockDetails(
                    context,
                    companyName: 'Reliance Industries',
                    symbol: 'RELIANCE',
                  ),
                ),
                _HoldingCard(
                  companyName: 'Tata Consultancy Services',
                  symbol: 'TCS',
                  quantity: '5 shares',
                  value: '₹20,629',
                  gain: '+₹820',
                  isPositive: true,
                  onTap: () => _openStockDetails(
                    context,
                    companyName: 'Tata Consultancy Services',
                    symbol: 'TCS',
                  ),
                ),
                _HoldingCard(
                  companyName: 'Infosys',
                  symbol: 'INFY',
                  quantity: '10 shares',
                  value: '₹14,852',
                  gain: '-₹350',
                  isPositive: false,
                  onTap: () => _openStockDetails(
                    context,
                    companyName: 'Infosys',
                    symbol: 'INFY',
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Add Holding Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _openAddHolding(context),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add New Holding',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Performance Card
class _PerformanceCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;

  const _PerformanceCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            if (percentage.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                percentage,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Allocation Row
class _AllocationRow extends StatelessWidget {
  final String name;
  final String percentage;
  final String value;

  const _AllocationRow({
    required this.name,
    required this.percentage,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.pie_chart_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          percentage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Holding Card
class _HoldingCard extends StatelessWidget {
  final String companyName;
  final String symbol;
  final String quantity;
  final String value;
  final String gain;
  final bool isPositive;
  final VoidCallback onTap;

  const _HoldingCard({
    required this.companyName,
    required this.symbol,
    required this.quantity,
    required this.value,
    required this.gain,
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
                      '$symbol • $quantity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    gain,
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
