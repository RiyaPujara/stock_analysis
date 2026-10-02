import 'package:flutter/material.dart';
import '../../services/watchlist_service.dart';
import '../stock/stock_details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _fallbackWatchlist = [
    {
      'companyName': 'Reliance Industries',
      'symbol': 'RELIANCE',
      'price': '₹2,945.50',
      'change': '+1.25%',
      'isPositive': true,
    },
    {
      'companyName': 'Tata Consultancy Services',
      'symbol': 'TCS',
      'price': '₹4,125.80',
      'change': '+0.82%',
      'isPositive': true,
    },
    {
      'companyName': 'Infosys',
      'symbol': 'INFY',
      'price': '₹1,485.20',
      'change': '-0.45%',
      'isPositive': false,
    },
    {
      'companyName': 'HDFC Bank',
      'symbol': 'HDFCBANK',
      'price': '₹1,875.40',
      'change': '+0.64%',
      'isPositive': true,
    },
    {
      'companyName': 'ICICI Bank',
      'symbol': 'ICICIBANK',
      'price': '₹1,425.70',
      'change': '-0.21%',
      'isPositive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    final list = await WatchlistService.instance.getWatchlist();

    if (mounted) {
      setState(() {
        _watchlist = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(String symbol) async {
    try {
      await WatchlistService.instance.removeFromWatchlist(symbol);
      _loadWatchlist();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$symbol removed from watchlist')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Watchlist'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Enter stock symbol (e.g. RELIANCE)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final symbol = controller.text.trim().toUpperCase();
                final messenger = ScaffoldMessenger.of(context);
                if (symbol.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    await WatchlistService.instance.addToWatchlist(symbol);
                    _loadWatchlist();
                    messenger.showSnackBar(
                      SnackBar(content: Text('$symbol added to watchlist')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _watchlist.isNotEmpty ? _watchlist : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Stock',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWatchlist,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              if (displayList != null)
                ...displayList.map((item) {
                  final sym = item['symbol'] ?? '';
                  final name = item['name'] ?? item['companyName'] ?? sym;
                  final price = ((item['currentPrice'] ?? 0.0) as num).toDouble();
                  final chg = ((item['changePercent'] ?? 0.0) as num).toDouble();
                  final isPos = chg >= 0;

                  return _WatchlistCard(
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
                      ).then((_) => _loadWatchlist());
                    },
                    onDelete: () => _removeItem(sym),
                  );
                })
              else if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._fallbackWatchlist.map(
                  (item) => _WatchlistCard(
                    companyName: item['companyName'],
                    symbol: item['symbol'],
                    price: item['price'],
                    change: item['change'],
                    isPositive: item['isPositive'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailsScreen(
                            companyName: item['companyName'],
                            symbol: item['symbol'],
                          ),
                        ),
                      );
                    },
                    onDelete: () {},
                  ),
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
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WatchlistCard({
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove from Watchlist'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}