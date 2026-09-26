import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
      ),
      body: SingleChildScrollView(
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
                    const Text(
                      '+₹12,450',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+11.05% overall',
                      style: TextStyle(
                        color: Colors.green.shade700,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
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
                    value: '₹1,25,000',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Invested',
                    value: '₹1,12,550',
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
                    value: '5',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Today',
                    value: '+1.98%',
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
                  children: [
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

            _PerformanceStockCard(
              company: 'Reliance Industries',
              symbol: 'RELIANCE',
              returnValue: '+18.40%',
              isPositive: true,
            ),
            _PerformanceStockCard(
              company: 'TCS',
              symbol: 'TCS',
              returnValue: '+14.25%',
              isPositive: true,
            ),
            _PerformanceStockCard(
              company: 'Infosys',
              symbol: 'INFY',
              returnValue: '-3.20%',
              isPositive: false,
            ),

            const SizedBox(height: 28),

            Text(
              'Risk & Diversification',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
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