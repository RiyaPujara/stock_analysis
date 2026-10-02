import 'package:flutter/material.dart';
import '../../services/portfolio_service.dart';
import '../../models/holding.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _summary;
  List<Holding> _holdings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await PortfolioService.instance.getSummary();
    final holdings = await PortfolioService.instance.getHoldings();
    if (mounted) {
      setState(() {
        _summary = summary;
        _holdings = holdings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = (_summary?['totalValue'] ?? 125000.0) as num;
    final invested = (_summary?['totalInvested'] ?? 112550.0) as num;
    final totalGainLoss = (_summary?['totalGainLoss'] ?? 12450.0) as num;
    final totalGainLossPct =
        (_summary?['totalGainLossPercent'] ?? 11.05) as num;
    final isPositive = totalGainLoss >= 0;
    final todayGainPct = (_summary?['todayGainPercent'] ?? 1.98) as num;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
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
                'Portfolio Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Return',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isPositive ? '+' : ''}₹${totalGainLoss.abs().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isPositive ? '+' : ''}${totalGainLossPct.toStringAsFixed(2)}% overall',
                        style: TextStyle(
                          color: isPositive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _PerformanceChartPainter(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('1M'),
                          Text('3M'),
                          Text('6M'),
                          Text('1Y'),
                          Text('All'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Key Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Current Value',
                      value: '₹${totalValue.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Invested',
                      value: '₹${invested.toStringAsFixed(0)}',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Holdings',
                      value: '${_holdings.isNotEmpty ? _holdings.length : 5}',
                      icon: Icons.pie_chart_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Today',
                      value:
                          '${todayGainPct >= 0 ? '+' : ''}${todayGainPct.toStringAsFixed(2)}%',
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                'Asset Allocation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: _holdings.isNotEmpty
                        ? _holdings.map((h) {
                            return _AllocationRow(
                              company: h.stockName.isNotEmpty
                                  ? h.stockName
                                  : h.stockSymbol,
                              percentage:
                                  '${h.allocationPercent.toStringAsFixed(1)}%',
                              value: '₹${h.totalValue.toStringAsFixed(0)}',
                            );
                          }).toList()
                        : const [
                            _AllocationRow(
                              company: 'Reliance Industries',
                              percentage: '30%',
                              value: '₹37,500',
                            ),
                            _AllocationRow(
                              company: 'TCS',
                              percentage: '25%',
                              value: '₹31,250',
                            ),
                            _AllocationRow(
                              company: 'Infosys',
                              percentage: '20%',
                              value: '₹25,000',
                            ),
                            _AllocationRow(
                              company: 'HDFC Bank',
                              percentage: '15%',
                              value: '₹18,750',
                            ),
                            _AllocationRow(
                              company: 'ICICI Bank',
                              percentage: '10%',
                              value: '₹12,500',
                            ),
                          ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Performance Leaders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              if (_holdings.isNotEmpty)
                ..._holdings.take(3).map((h) {
                  final isPos = h.gainLossPercentage >= 0;
                  return _PerformanceStockCard(
                    company:
                        h.stockName.isNotEmpty ? h.stockName : h.stockSymbol,
                    symbol: h.stockSymbol,
                    returnValue:
                        '${isPos ? '+' : ''}${h.gainLossPercentage.toStringAsFixed(2)}%',
                    isPositive: isPos,
                  );
                })
              else ...[
                const _PerformanceStockCard(
                  company: 'Reliance Industries',
                  symbol: 'RELIANCE',
                  returnValue: '+18.40%',
                  isPositive: true,
                ),
                const _PerformanceStockCard(
                  company: 'TCS',
                  symbol: 'TCS',
                  returnValue: '+14.25%',
                  isPositive: true,
                ),
                const _PerformanceStockCard(
                  company: 'Infosys',
                  symbol: 'INFY',
                  returnValue: '-3.20%',
                  isPositive: false,
                ),
              ],

              const SizedBox(height: 28),

              Text(
                'Risk & Diversification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _RiskRow(
                        title: 'Diversification',
                        value: 'Good',
                        icon: Icons.pie_chart_outline,
                      ),
                      _RiskRow(
                        title: 'Portfolio Risk',
                        value: 'Moderate',
                        icon: Icons.shield_outlined,
                      ),
                      _RiskRow(
                        title: 'Sector Exposure',
                        value: 'Balanced',
                        icon: Icons.business_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  final String company;
  final String percentage;
  final String value;

  const _AllocationRow({
    required this.company,
    required this.percentage,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              company,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            percentage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 75,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceStockCard extends StatelessWidget {
  final String company;
  final String symbol;
  final String returnValue;
  final bool isPositive;

  const _PerformanceStockCard({
    required this.company,
    required this.symbol,
    required this.returnValue,
    required this.isPositive,
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
            Icons.show_chart,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          company,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(symbol),
        trailing: Text(
          returnValue,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _RiskRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    path.moveTo(0, size.height * 0.75);
    path.lineTo(size.width * 0.12, size.height * 0.68);
    path.lineTo(size.width * 0.24, size.height * 0.72);
    path.lineTo(size.width * 0.36, size.height * 0.55);
    path.lineTo(size.width * 0.48, size.height * 0.60);
    path.lineTo(size.width * 0.60, size.height * 0.42);
    path.lineTo(size.width * 0.72, size.height * 0.48);
    path.lineTo(size.width * 0.84, size.height * 0.30);
    path.lineTo(size.width, size.height * 0.20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}