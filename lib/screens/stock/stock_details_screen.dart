import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../models/historical_price.dart';
import '../../services/market_service.dart';
import '../../services/watchlist_service.dart';
import '../alerts/alerts_screen.dart';
import '../simulator/what_if_simulator_screen.dart';

class StockDetailsScreen extends StatefulWidget {
  final String companyName;
  final String symbol;

  const StockDetailsScreen({
    super.key,
    this.companyName = 'Reliance Industries',
    this.symbol = 'RELIANCE',
  });

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  Map<String, dynamic>? _details;
  Map<String, dynamic>? _fundamentals;
  bool _isLoading = true;
  bool _isWatchlisted = false;
  bool _isAddingToWatchlist = false;

  String _selectedPeriod = '1D';
  List<HistoricalPrice> _historicalPrices = [];
  bool _isLoadingChart = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchHistoricalData('1D');
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final details = await MarketService.instance.getStockDetails(widget.symbol);
    final fundamentals =
        await MarketService.instance.getFundamentals(widget.symbol);

    if (mounted) {
      setState(() {
        _details = details;
        _fundamentals = fundamentals.toJson();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHistoricalData(String period) async {
    setState(() {
      _selectedPeriod = period;
      _isLoadingChart = true;
    });

    try {
      final prices = await MarketService.instance.getHistoricalPrices(widget.symbol, period: period);
      if (mounted) {
        setState(() {
          _historicalPrices = prices;
          _isLoadingChart = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingChart = false);
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    setState(() {
      _isAddingToWatchlist = true;
    });

    try {
      if (_isWatchlisted) {
        await WatchlistService.instance.removeFromWatchlist(widget.symbol);
        setState(() {
          _isWatchlisted = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.symbol} removed from watchlist'),
          ),
        );
      } else {
        await WatchlistService.instance.addToWatchlist(widget.symbol);
        setState(() {
          _isWatchlisted = true;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.symbol} added to watchlist'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToWatchlist = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice =
        ((_details?['currentPrice'] ?? 2945.50) as num).toDouble();
    final change = ((_details?['change'] ?? 36.40) as num).toDouble();
    final changePercent =
        ((_details?['changePercent'] ?? 1.25) as num).toDouble();
    final isPositive = change >= 0;

    final open = ((_details?['open'] ?? 2910.00) as num).toDouble();
    final high = ((_details?['dayHigh'] ?? 2970.00) as num).toDouble();
    final low = ((_details?['dayLow'] ?? 2895.00) as num).toDouble();
    final prevClose =
        ((_details?['previousClose'] ?? 2909.10) as num).toDouble();
    final volume = _details?['volume'] != null
        ? '${((_details!['volume'] as num) / 1000000).toStringAsFixed(2)}M'
        : '8.42M';
    final high52 =
        ((_details?['fiftyTwoWeekHigh'] ?? 3024.90) as num).toDouble();
    final low52 = ((_details?['fiftyTwoWeekLow'] ?? 2221.00) as num).toDouble();

    final marketCap = _fundamentals?['marketCap'] != null
        ? '₹${((_fundamentals!['marketCap'] as num) / 1000000000000).toStringAsFixed(2)}T'
        : '₹19.95T';
    final peRatio = _fundamentals?['peRatio'] != null
        ? ((_fundamentals!['peRatio'] as num)).toStringAsFixed(2)
        : '24.82';
    final dividendYield = _fundamentals?['dividendYield'] != null
        ? '${((_fundamentals!['dividendYield'] as num)).toStringAsFixed(2)}%'
        : '0.38%';
    final eps = _fundamentals?['eps'] != null
        ? '₹${((_fundamentals!['eps'] as num)).toStringAsFixed(2)}'
        : '₹118.62';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertsScreen(
                    initialSymbol: widget.symbol,
                    initialPrice: currentPrice,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_alert_outlined),
            tooltip: 'Set Price Alert',
          ),
          IconButton(
            onPressed: _isAddingToWatchlist ? null : _toggleWatchlist,
            icon: Icon(
              _isWatchlisted ? Icons.star : Icons.star_border,
              color: _isWatchlisted ? Colors.amber : null,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Text(
              _details?['name'] ?? widget.companyName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Text(
                  widget.symbol,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00DC82).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00DC82).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'LIVE • NSE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00DC82),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Current Price
            Text(
              '₹${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  '${isPositive ? '+' : ''}₹${change.abs().toStringAsFixed(2)} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
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

            // Chart Header with Period Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Chart ($_selectedPeriod)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_historicalPrices.length >= 2) ...[
                      const SizedBox(height: 2),
                      Builder(builder: (ctx) {
                        final first = _historicalPrices.first.close;
                        final last = _historicalPrices.last.close;
                        final diff = last - first;
                        final pct = (diff / (first > 0 ? first : 1)) * 100;
                        final isPos = diff >= 0;
                        return Text(
                          '${isPos ? '+' : ''}₹${diff.toStringAsFixed(2)} (${isPos ? '+' : ''}${pct.toStringAsFixed(2)}%) ${_selectedPeriod == '1D' ? 'Today' : _selectedPeriod == '1W' ? 'Past Week' : 'Past Period'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPos ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                if (_historicalPrices.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_historicalPrices.length} points',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
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
              child: _isLoadingChart
                  ? const Center(child: CircularProgressIndicator())
                  : CustomPaint(
                      painter: _StockChartPainter(
                        prices: _historicalPrices,
                        isPositive: _historicalPrices.length >= 2
                            ? (_historicalPrices.last.close >= _historicalPrices.first.close)
                            : isPositive,
                        chartColor: _historicalPrices.length >= 2
                            ? (_historicalPrices.last.close >= _historicalPrices.first.close
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            : (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Time Periods
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['1D', '1W', '1M', '6M', '1Y'].map((p) {
                return _TimeButton(
                  label: p,
                  selected: _selectedPeriod == p,
                  onTap: () => _fetchHistoricalData(p),
                );
              }).toList(),
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
                      value: '₹${open.toStringAsFixed(2)}',
                    ),
                    _StatRow(
                      title: 'Day High',
                      value: '₹${high.toStringAsFixed(2)}',
                    ),
                    _StatRow(
                      title: 'Day Low',
                      value: '₹${low.toStringAsFixed(2)}',
                    ),
                    _StatRow(
                      title: 'Previous Close',
                      value: '₹${prevClose.toStringAsFixed(2)}',
                    ),
                    _StatRow(
                      title: 'Volume',
                      value: volume,
                    ),
                    _StatRow(
                      title: '52 Week High',
                      value: '₹${high52.toStringAsFixed(2)}',
                    ),
                    _StatRow(
                      title: '52 Week Low',
                      value: '₹${low52.toStringAsFixed(2)}',
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
                    value: marketCap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FundamentalCard(
                    title: 'P/E Ratio',
                    value: peRatio,
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
                    value: dividendYield,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FundamentalCard(
                    title: 'EPS',
                    value: eps,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Run Gemini AI What-If Analysis
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WhatIfSimulatorScreen(
                        initialSymbol: widget.symbol,
                        initialPrice: currentPrice,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                label: const Text(
                  'Run Gemini AI What-If Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Add to Watchlist
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isAddingToWatchlist ? null : _toggleWatchlist,
                icon: Icon(_isWatchlisted ? Icons.star : Icons.star_border),
                label: Text(
                  _isWatchlisted
                      ? 'Remove from Watchlist'
                      : 'Add to Watchlist',
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

// Time period button
class _TimeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeButton({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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

// Dynamic stock chart painter for 1D, 1W, and multi-period series
class _StockChartPainter extends CustomPainter {
  final List<HistoricalPrice> prices;
  final bool isPositive;
  final Color chartColor;

  _StockChartPainter({
    required this.prices,
    required this.isPositive,
    required this.chartColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    double minPrice = prices.first.close;
    double maxPrice = prices.first.close;
    for (final p in prices) {
      if (p.close < minPrice) minPrice = p.close;
      if (p.close > maxPrice) maxPrice = p.close;
    }

    if (minPrice == maxPrice) {
      minPrice *= 0.99;
      maxPrice *= 1.01;
    }

    final priceRange = maxPrice - minPrice;
    final padding = size.height * 0.12;
    final usableHeight = size.height - (padding * 2);

    final linePaint = Paint()
      ..color = chartColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (prices.length - 1 > 0 ? (prices.length - 1) : 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final normalizedY = (prices[i].close - minPrice) / priceRange;
      final y = size.height - padding - (normalizedY * usableHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill vertical gradient under the line chart
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [
          chartColor.withValues(alpha: 0.28),
          chartColor.withValues(alpha: 0.0),
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw pulsating indicator on latest point
    final lastNormalizedY = (prices.last.close - minPrice) / priceRange;
    final lastY = size.height - padding - (lastNormalizedY * usableHeight);
    final dotPaint = Paint()..color = chartColor;
    final glowPaint = Paint()..color = chartColor.withValues(alpha: 0.35);

    canvas.drawCircle(Offset(size.width, lastY), 7, glowPaint);
    canvas.drawCircle(Offset(size.width, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _StockChartPainter oldDelegate) {
    return oldDelegate.prices != prices || oldDelegate.chartColor != chartColor;
  }
}