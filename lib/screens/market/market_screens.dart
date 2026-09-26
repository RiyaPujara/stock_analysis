import 'package:flutter/material.dart';

import '../stock/stock_details_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  final List<Map<String, dynamic>> _stocks = [
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStocks {
    if (_searchQuery.isEmpty) {
      return _stocks;
    }

    return _stocks.where((stock) {
      final companyName =
          stock['companyName'].toString().toLowerCase();
      final symbol =
          stock['symbol'].toString().toLowerCase();

      return companyName.contains(_searchQuery) ||
          symbol.contains(_searchQuery);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = _filteredStocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Market Overview
            Text(
              'Market Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MarketIndexCard(
                    name: 'NIFTY 50',
                    value: '25,350.20',
                    change: '+0.72%',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MarketIndexCard(
                    name: 'SENSEX',
                    value: '82,450.30',
                    change: '+0.58%',
                    isPositive: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Popular Stocks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Stocks',
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

            if (filteredStocks.isEmpty)
              _NoStocksFound()
            else
              ...filteredStocks.map(
                (stock) => _StockCard(
                  companyName: stock['companyName'],
                  symbol: stock['symbol'],
                  price: stock['price'],
                  change: stock['change'],
                  isPositive: stock['isPositive'],
                ),
              ),

            const SizedBox(height: 28),

            // Market Sectors
            Text(
              'Market Sectors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SectorCard(
                    title: 'Banking',
                    icon: Icons.account_balance,
                    change: '+1.12%',
                    isPositive: true,
                  ),
                  _SectorCard(
                    title: 'IT',
                    icon: Icons.computer,
                    change: '+0.84%',
                    isPositive: true,
                  ),
                  _SectorCard(
                    title: 'Pharma',
                    icon: Icons.medical_services_outlined,
                    change: '-0.32%',
                    isPositive: false,
                  ),
                  _SectorCard(
                    title: 'Auto',
                    icon: Icons.directions_car_outlined,
                    change: '+0.56%',
                    isPositive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// No Stocks Found
class _NoStocksFound extends StatelessWidget {
  const _NoStocksFound();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 45,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              const Text(
                'No stocks found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Try searching with another name or symbol.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Market Index Card
class _MarketIndexCard extends StatelessWidget {
  final String name;
  final String value;
  final String change;
  final bool isPositive;

  const _MarketIndexCard({
    required this.name,
    required this.value,
    required this.change,
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
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              change,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stock Card
class _StockCard extends StatelessWidget {
  final String companyName;
  final String symbol;
  final String price;
  final String change;
  final bool isPositive;

  const _StockCard({
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailsScreen(
                companyName: companyName,
                symbol: symbol,
              ),
            ),
          );
        },
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
            ],
          ),
        ),
      ),
    );
  }
}

// Sector Card
class _SectorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String change;
  final bool isPositive;

  const _SectorCard({
    required this.title,
    required this.icon,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}