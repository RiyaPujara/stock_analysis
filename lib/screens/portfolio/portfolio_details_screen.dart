import 'package:flutter/material.dart';
import '../../services/portfolio_service.dart';
import '../../models/holding.dart';

class PortfolioDetailsScreen extends StatefulWidget {
  const PortfolioDetailsScreen({super.key});

  @override
  State<PortfolioDetailsScreen> createState() => _PortfolioDetailsScreenState();
}

class _PortfolioDetailsScreenState extends State<PortfolioDetailsScreen> {
  Map<String, dynamic>? _summary;
  List<Holding> _holdings = [];
  List<Map<String, dynamic>> _transactions = [];
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
    final transactions = await PortfolioService.instance.getTransactions();

    if (mounted) {
      setState(() {
        _summary = summary;
        _holdings = holdings;
        _transactions = transactions.map((t) => t.toJson()).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = (_summary?['totalValue'] ?? 125000.0) as num;
    final totalGainLoss = (_summary?['totalGainLoss'] ?? 12450.0) as num;
    final totalGainLossPercent =
        (_summary?['totalGainLossPercent'] ?? 11.05) as num;
    final isOverallPositive = totalGainLoss >= 0;

    final invested = (_summary?['totalInvested'] ?? 112550.0) as num;
    final todayGainPercent = (_summary?['todayGainPercent'] ?? 1.98) as num;
    final isTodayPositive = todayGainPercent >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      Text(
                        '₹${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isOverallPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isOverallPositive ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${isOverallPositive ? '+' : ''}₹${totalGainLoss.abs().toStringAsFixed(2)} (${isOverallPositive ? '+' : ''}${totalGainLossPercent.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color:
                                  isOverallPositive ? Colors.green : Colors.red,
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
                      value: '₹${invested.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Gain',
                      value:
                          '${isOverallPositive ? '+' : ''}₹${totalGainLoss.abs().toStringAsFixed(2)}',
                      icon: isOverallPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      isPositive: isOverallPositive,
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
                      value: '${_holdings.isNotEmpty ? _holdings.length : 4} Stocks',
                      icon: Icons.pie_chart_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Today',
                      value:
                          '${isTodayPositive ? '+' : ''}${todayGainPercent.toStringAsFixed(2)}%',
                      icon: Icons.show_chart,
                      isPositive: isTodayPositive,
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
                    children: _holdings.isNotEmpty
                        ? _holdings.map((h) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _AllocationItem(
                                name: h.stockName.isNotEmpty
                                    ? h.stockName
                                    : h.stockSymbol,
                                symbol: h.stockSymbol,
                                percentage:
                                    '${h.allocationPercent.toStringAsFixed(1)}%',
                                value: '₹${h.totalValue.toStringAsFixed(2)}',
                              ),
                            );
                          }).toList()
                        : [
                            const _AllocationItem(
                              name: 'Reliance Industries',
                              symbol: 'RELIANCE',
                              percentage: '23.6%',
                              value: '₹29,455',
                            ),
                            const Divider(height: 28),
                            const _AllocationItem(
                              name: 'Tata Consultancy Services',
                              symbol: 'TCS',
                              percentage: '16.5%',
                              value: '₹20,629',
                            ),
                            const Divider(height: 28),
                            const _AllocationItem(
                              name: 'Infosys',
                              symbol: 'INFY',
                              percentage: '11.9%',
                              value: '₹14,852',
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
                    onPressed: _loadData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_transactions.isNotEmpty)
                ..._transactions.map((t) {
                  final type = (t['type'] ?? 'BUY').toString().toUpperCase();
                  final isBuy = type != 'SELL';
                  final sym = t['symbol'] ?? '';
                  final name = t['stockName'] ?? sym;
                  final qty = t['quantity'] ?? 0;
                  final price = (t['price'] as num?)?.toDouble() ?? 0.0;
                  final date = t['createdAt'] != null
                      ? t['createdAt'].toString().substring(0, 10)
                      : 'Recent';

                  return _TransactionCard(
                    companyName: name,
                    symbol: sym,
                    type: type,
                    quantity: '$qty shares',
                    price: '₹${price.toStringAsFixed(2)}',
                    date: date,
                    isBuy: isBuy,
                  );
                })
              else ...[
                const _TransactionCard(
                  companyName: 'Reliance Industries',
                  symbol: 'RELIANCE',
                  type: 'Buy',
                  quantity: '10 shares',
                  price: '₹2,850',
                  date: '20 Sep 2026',
                  isBuy: true,
                ),
                const _TransactionCard(
                  companyName: 'Tata Consultancy Services',
                  symbol: 'TCS',
                  type: 'Buy',
                  quantity: '5 shares',
                  price: '₹3,950',
                  date: '18 Sep 2026',
                  isBuy: true,
                ),
                const _TransactionCard(
                  companyName: 'Infosys',
                  symbol: 'INFY',
                  type: 'Buy',
                  quantity: '10 shares',
                  price: '₹1,520',
                  date: '15 Sep 2026',
                  isBuy: true,
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
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
