import 'package:flutter/material.dart';

class StockDetailsScreen extends StatelessWidget {
  final String companyName;
  final String symbol;

  const StockDetailsScreen({
    super.key,
    this.companyName = 'Reliance Industries',
    this.symbol = 'RELIANCE',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Text(
              companyName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              symbol,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            // Current Price
            const Text(
              '₹2,945.50',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 5),
                const Text(
                  '+₹36.40 (+1.25%)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Chart
            Text(
              'Price Chart',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                painter: _StockChartPainter(),
              ),
            ),

            const SizedBox(height: 16),

            // Time Periods
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TimeButton(label: '1D', selected: true),
                _TimeButton(label: '1W'),
                _TimeButton(label: '1M'),
                _TimeButton(label: '6M'),
                _TimeButton(label: '1Y'),
              ],
            ),

            const SizedBox(height: 30),

            // Market Statistics
            Text(
              'Market Statistics',
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
                    _StatRow(
                      title: 'Open',
                      value: '₹2,910.00',
                    ),
                    _StatRow(
                      title: 'Day High',
                      value: '₹2,970.00',
                    ),
                    _StatRow(
                      title: 'Day Low',
                      value: '₹2,895.00',
                    ),
                    _StatRow(
                      title: 'Previous Close',
                      value: '₹2,909.10',
                    ),
                    _StatRow(
                      title: 'Volume',
                      value: '8.42M',
                    ),
                    _StatRow(
                      title: '52 Week High',
                      value: '₹3,024.90',
                    ),
                    _StatRow(
                      title: '52 Week Low',
                      value: '₹2,221.00',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Fundamentals
            Text(
              'Fundamentals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _FundamentalCard(
                    title: 'Market Cap',
                    value: '₹19.95T',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FundamentalCard(
                    title: 'P/E Ratio',
                    value: '24.82',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _FundamentalCard(
                    title: 'Dividend Yield',
                    value: '0.38%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FundamentalCard(
                    title: 'EPS',
                    value: '₹118.62',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Add to Watchlist
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star_border),
                label: const Text('Add to Watchlist'),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Time period button
class _TimeButton extends StatelessWidget {
  final String label;
  final bool selected;

  const _TimeButton({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

// Statistics row
class _StatRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Fundamental card
class _FundamentalCard extends StatelessWidget {
  final String title;
  final String value;

  const _FundamentalCard({
    required this.title,
    required this.value,
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary stock chart
class _StockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height * 0.75);

    path.lineTo(size.width * 0.10, size.height * 0.65);
    path.lineTo(size.width * 0.20, size.height * 0.70);
    path.lineTo(size.width * 0.30, size.height * 0.45);
    path.lineTo(size.width * 0.40, size.height * 0.55);
    path.lineTo(size.width * 0.50, size.height * 0.30);
    path.lineTo(size.width * 0.60, size.height * 0.40);
    path.lineTo(size.width * 0.70, size.height * 0.20);
    path.lineTo(size.width * 0.80, size.height * 0.35);
    path.lineTo(size.width * 0.90, size.height * 0.15);
    path.lineTo(size.width, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}