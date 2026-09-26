import 'package:flutter/material.dart';

class PortfolioDetailsScreen extends StatelessWidget {
  const PortfolioDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Value
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₹1,25,000.00',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '+₹12,450 (11.05%)',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Performance Summary
            Text(
              'Performance Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Invested',
                    value: '₹1,12,550',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Gain',
                    value: '+₹12,450',
                    icon: Icons.trending_up,
                    isPositive: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Holdings',
                    value: '4 Stocks',
                    icon: Icons.pie_chart_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Today',
                    value: '+1.98%',
                    icon: Icons.show_chart,
                    isPositive: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Portfolio Allocation
            Text(
              'Portfolio Allocation',
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
                    _AllocationItem(
                      name: 'Reliance Industries',
                      symbol: 'RELIANCE',
                      percentage: '23.6%',
                      value: '₹29,455',
                    ),
                    const Divider(height: 28),
                    _AllocationItem(
                      name: 'Tata Consultancy Services',
                      symbol: 'TCS',
                      percentage: '16.5%',
                      value: '₹20,629',
                    ),
                    const Divider(height: 28),
                    _AllocationItem(
                      name: 'Infosys',
                      symbol: 'INFY',
                      percentage: '11.9%',
                      value: '₹14,852',
                    ),
                    const Divider(height: 28),
                    _AllocationItem(
                      name: 'HDFC Bank',
                      symbol: 'HDFCBANK',
                      percentage: '12.0%',
                      value: '₹15,003',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Transaction History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _TransactionCard(
              companyName: 'Reliance Industries',
              symbol: 'RELIANCE',
              type: 'Buy',
              quantity: '10 shares',
              price: '₹2,850',
              date: '20 Sep 2026',
              isBuy: true,
            ),

            _TransactionCard(
              companyName: 'Tata Consultancy Services',
              symbol: 'TCS',
              type: 'Buy',
              quantity: '5 shares',
              price: '₹3,950',
              date: '18 Sep 2026',
              isBuy: true,
            ),

            _TransactionCard(
              companyName: 'Infosys',
              symbol: 'INFY',
              type: 'Buy',
              quantity: '10 shares',
              price: '₹1,520',
              date: '15 Sep 2026',
              isBuy: true,
            ),

            _TransactionCard(
              companyName: 'HDFC Bank',
              symbol: 'HDFCBANK',
              type: 'Buy',
              quantity: '8 shares',
              price: '₹1,810',
              date: '12 Sep 2026',
              isBuy: true,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Summary Card
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isPositive = false,
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
              size: 24,
              color: isPositive
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Allocation Item
class _AllocationItem extends StatelessWidget {
  final String name;
  final String symbol;
  final String percentage;
  final String value;

  const _AllocationItem({
    required this.name,
    required this.symbol,
    required this.percentage,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                name,
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
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              percentage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

// Transaction Card
class _TransactionCard extends StatelessWidget {
  final String companyName;
  final String symbol;
  final String type;
  final String quantity;
  final String price;
  final String date;
  final bool isBuy;

  const _TransactionCard({
    required this.companyName,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isBuy
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
              child: Icon(
                isBuy
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: isBuy ? Colors.green : Colors.red,
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
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    color: isBuy ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
