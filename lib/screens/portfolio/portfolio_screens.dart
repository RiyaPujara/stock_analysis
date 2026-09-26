import 'package:flutter/material.dart';

import '../stock/stock_details_screen.dart';
import 'add_holding_screen.dart';
import 'portfolio_details_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  void _openAddHolding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHoldingScreen(),
      ),
    );
  }

  void _openPortfolioDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PortfolioDetailsScreen(),
      ),
    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        actions: [
          IconButton(
            onPressed: () => _openAddHolding(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add Holding',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹1,25,000.00',
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
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+₹12,450 (11.05%)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Overall',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => _openPortfolioDetails(context),
                    icon: Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      'View Portfolio Details',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.6),
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
                    value: '+₹2,450',
                    percentage: '+1.98%',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PerformanceCard(
                    title: 'Invested',
                    value: '₹1,12,550',
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
                    const _AllocationRow(
                      name: 'Stocks',
                      percentage: '80%',
                      value: '₹1,00,000',
                    ),
                    const Divider(height: 24),
                    const _AllocationRow(
                      name: 'Cash',
                      percentage: '15%',
                      value: '₹18,750',
                    ),
                    const Divider(height: 24),
                    const _AllocationRow(
                      name: 'Other',
                      percentage: '5%',
                      value: '₹6,250',
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

            _HoldingCard(
              companyName: 'HDFC Bank',
              symbol: 'HDFCBANK',
              quantity: '8 shares',
              value: '₹15,003',
              gain: '+₹540',
              isPositive: true,
              onTap: () => _openStockDetails(
                context,
                companyName: 'HDFC Bank',
                symbol: 'HDFCBANK',
              ),
            ),

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
