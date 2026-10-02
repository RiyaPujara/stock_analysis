import 'package:flutter/material.dart';
import '../../services/market_service.dart';
import '../../services/watchlist_service.dart';
import '../alerts/alerts_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
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

            Text(
              widget.symbol,
              style: Theme.of(context).textTheme.bodyMedium,
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

            // Add to Watchlist
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
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