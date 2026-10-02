import 'package:flutter/material.dart';
import '../stock/stock_details_screen.dart';
import '../simulator/what_if_simulator_screen.dart';
import '../../services/market_service.dart';
import '../../models/market_index.dart';
import '../../utils/app_theme.dart';

class MarketScreen extends StatefulWidget {
  final bool showAppBar;
  const MarketScreen({super.key, this.showAppBar = false});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  // Initialize with the full master list of Indian stocks so it's NEVER empty!
  List<Map<String, dynamic>> _stocks = MarketService.masterStocks;
  List<MarketIndex> _indices = [];
  bool _isRefreshing = false;
  String _currentApiSource = MarketService.activeSource;

  final List<String> _categories = [
    'All',
    'Nifty 50',
    'Banking',
    'Technology',
    'Automobile',
    'Energy',
    'Top Gainers',
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isRefreshing = true);

    try {
      final indices = await MarketService.instance.getIndices();
      final freshStocks = await MarketService.instance.getRealtimeBatch();

      if (mounted) {
        setState(() {
          _indices = indices;
          if (freshStocks.isNotEmpty) {
            _stocks = freshStocks;
          }
          _currentApiSource = MarketService.activeSource;
          _isRefreshing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() => _searchQuery = query);
    if (query.trim().isNotEmpty) {
      final results = await MarketService.instance.searchRealtimeStocks(query);
      if (mounted) {
        setState(() => _stocks = results);
      }
    } else if (query.trim().isEmpty) {
      _loadMarketData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStocks {
    var list = _stocks;

    if (_selectedCategory == 'Top Gainers') {
      list = list.where((s) {
        final chg = ((s['changePercent'] ?? 0.0) as num).toDouble();
        return chg > 0;
      }).toList();
    } else if (_selectedCategory == 'Banking') {
      list = list.where((s) {
        final sec = (s['sector'] ?? '').toString().toLowerCase();
        return sec.contains('bank') || sec.contains('financial');
      }).toList();
    } else if (_selectedCategory == 'Technology') {
      list = list.where((s) {
        final sec = (s['sector'] ?? '').toString().toLowerCase();
        return sec.contains('tech') || sec.contains('it');
      }).toList();
    } else if (_selectedCategory == 'Automobile') {
      list = list.where((s) {
        final sec = (s['sector'] ?? '').toString().toLowerCase();
        return sec.contains('auto');
      }).toList();
    } else if (_selectedCategory == 'Energy') {
      list = list.where((s) {
        final sec = (s['sector'] ?? '').toString().toLowerCase();
        return sec.contains('energy') || sec.contains('power') || sec.contains('oil');
      }).toList();
    } else if (_selectedCategory == 'Nifty 50') {
      // Top prominent Nifty 50 constituents
      final niftySymbols = {
        'RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'ICICIBANK',
        'BHARTIARTL', 'SBIN', 'TATAMOTORS', 'TATASTEEL', 'ITC',
        'WIPRO', 'HINDUNILVR', 'BAJFINANCE', 'MARUTI', 'SUNPHARMA',
        'AXISBANK', 'KOTAKBANK', 'LT', 'TITAN', 'ADANIENT',
        'ADANIPORTS', 'NTPC', 'POWERGRID', 'COALINDIA', 'M&M',
        'ULTRACEMCO', 'ASIANPAINT', 'HCLTECH', 'CIPLA', 'JSWSTEEL'
      };
      list = list.where((s) => niftySymbols.contains(s['symbol'])).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((s) {
        final name = (s['companyName'] ?? s['name'] ?? '').toString().toLowerCase();
        final sym = (s['symbol'] ?? '').toString().toLowerCase();
        final sec = (s['sector'] ?? '').toString().toLowerCase();
        return name.contains(q) || sym.contains(q) || sec.contains(q);
      }).toList();
    }

    return list;
  }

  void _showApiSettingsDialog() {
    final urlController = TextEditingController(text: MarketService.customIndianStockApiUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hub_rounded, color: AppTheme.primaryEmerald),
            SizedBox(width: 8),
            Text('Indian Stock Market API'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connected to 0xramm Indian-Stock-Market-API. You can point to your local Flask service (http://127.0.0.1:5000) or any deployed instance.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
                hintText: 'http://127.0.0.1:5000',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Current Active Status: $_currentApiSource',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              MarketService.customIndianStockApiUrl = urlController.text.trim();
              Navigator.pop(ctx);
              _loadMarketData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API URL updated and data reloaded!')),
              );
            },
            child: const Text('Save & Reconnect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Live Indian Markets'),
              actions: [
                IconButton(
                  tooltip: 'Configure Indian Stock Market API',
                  onPressed: _showApiSettingsDialog,
                  icon: const Icon(Icons.settings_input_component_rounded),
                ),
                IconButton(
                  tooltip: 'Refresh Real-time Quotes',
                  onPressed: () {
                    _loadMarketData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Syncing live data from $_currentApiSource...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadMarketData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indian Stock Market API Badge Bar
              InkWell(
                onTap: _showApiSettingsDialog,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '0xramm Indian-Stock-Market-API (Live NSE & BSE)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryEmerald,
                              ),
                            ),
                            Text(
                              'Status: $_currentApiSource',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.primaryEmerald),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Realtime Indices Section
              const Text(
                'Key Benchmarks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_indices.isNotEmpty
                          ? _indices
                          : [
                              MarketIndex(name: 'NIFTY 50', symbol: '^NSEI', currentValue: 22421.95, change: -198.45, changePercent: -0.88),
                              MarketIndex(name: 'SENSEX', symbol: '^BSESN', currentValue: 71909.70, change: -612.30, changePercent: -0.84),
                              MarketIndex(name: 'BANK NIFTY', symbol: '^NSEBANK', currentValue: 54450.75, change: 240.50, changePercent: 0.44),
                              MarketIndex(name: 'NIFTY IT', symbol: '^CNXIT', currentValue: 28304.70, change: -115.20, changePercent: -0.40),
                            ])
                      .map((idx) {
                    final isPos = idx.changePercent >= 0;
                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isPos
                              ? AppTheme.primaryEmerald.withValues(alpha: 0.25)
                              : AppTheme.dangerRed.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idx.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${idx.currentValue.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPos ? Icons.trending_up : Icons.trending_down,
                                size: 16,
                                color: isPos ? AppTheme.successGreen : AppTheme.dangerRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPos ? '+' : ''}${idx.changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPos ? AppTheme.successGreen : AppTheme.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search 30+ Indian stocks (Reliance, TCS, HDFC, Tata, ITC)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryEmerald : null,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Stocks List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Indian Equities (${_filteredStocks.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_isRefreshing)
                    const Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Updating Live...',
                          style: TextStyle(fontSize: 11, color: AppTheme.primaryEmerald),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_filteredStocks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF64748B)),
                      SizedBox(height: 12),
                      Text('No matching Indian equities found'),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredStocks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredStocks[index];
                    final sym = item['symbol'] ?? '';
                    final name = item['companyName'] ?? item['name'] ?? sym;
                    final priceVal = ((item['currentPrice'] ?? 0.0) as num).toDouble();
                    final chgVal = ((item['changePercent'] ?? 0.0) as num).toDouble();
                    final isPos = chgVal >= 0;
                    final exchange = item['exchange'] ?? 'NSE';
                    final sector = item['sector'] ?? 'Equities';

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsScreen(
                                  companyName: name,
                                  symbol: sym,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Company Symbol Badge
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A2333)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF243048)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    sym.length > 4 ? sym.substring(0, 4) : sym,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: AppTheme.primaryEmerald,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Name & Sector
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFE2E8F0),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              exchange,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            sym,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            '•',
                                            style: TextStyle(color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            sector,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Price & Change
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${priceVal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPos
                                            ? AppTheme.successGreen.withValues(alpha: 0.15)
                                            : AppTheme.dangerRed.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${isPos ? '+' : ''}${chgVal.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPos
                                              ? AppTheme.successGreen
                                              : AppTheme.dangerRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 6),

                                // Quick AI What-If Icon Button
                                IconButton(
                                  tooltip: 'Run Gemini AI What-If Analysis',
                                  icon: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppTheme.accentPurple,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WhatIfSimulatorScreen(
                                          initialSymbol: sym,
                                          initialPrice: priceVal,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}