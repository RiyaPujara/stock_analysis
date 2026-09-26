import 'package:flutter/material.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Watchlist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              'Keep track of stocks you are interested in',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 24),

            _WatchlistCard(
              companyName: 'Reliance Industries',
              symbol: 'RELIANCE',
              price: '₹2,945.50',
              change: '+1.25%',
              isPositive: true,
            ),

            _WatchlistCard(
              companyName: 'Tata Consultancy Services',
              symbol: 'TCS',
              price: '₹4,125.80',
              change: '+0.82%',
              isPositive: true,
            ),

            _WatchlistCard(
              companyName: 'Infosys',
              symbol: 'INFY',
              price: '₹1,485.20',
              change: '-0.45%',
              isPositive: false,
            ),

            _WatchlistCard(
              companyName: 'HDFC Bank',
              symbol: 'HDFCBANK',
              price: '₹1,875.40',
              change: '+0.64%',
              isPositive: true,
            ),

            _WatchlistCard(
              companyName: 'ICICI Bank',
              symbol: 'ICICIBANK',
              price: '₹1,425.70',
              change: '-0.21%',
              isPositive: false,
            ),

            const SizedBox(height: 20),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stocks in your watchlist can be monitored '
                        'without adding them to your portfolio.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Watchlist Card
class _WatchlistCard extends StatelessWidget {
  final String companyName;
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;

  const _WatchlistCard({
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  const SizedBox(height: 4),
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
                const SizedBox(height: 4),
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

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}