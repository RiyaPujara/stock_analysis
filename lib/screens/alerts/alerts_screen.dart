import 'package:flutter/material.dart';
import '../../models/price_alert.dart';
import '../../services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  final String? initialSymbol;
  final double? initialPrice;

  const AlertsScreen({
    super.key,
    this.initialSymbol,
    this.initialPrice,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<PriceAlert> _alerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    if (widget.initialSymbol != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddAlertDialog(
          presetSymbol: widget.initialSymbol,
          presetPrice: widget.initialPrice,
        );
      });
    }
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });

    final alerts = await AlertService.instance.getAlerts();

    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAlert(PriceAlert alert) async {
    final alertId = alert.alertId ?? alert.id.toString();
    await AlertService.instance.toggleAlert(alertId);
    _loadAlerts();
  }

  Future<void> _deleteAlert(PriceAlert alert) async {
    final alertId = alert.alertId ?? alert.id.toString();
    try {
      await AlertService.instance.deleteAlert(alertId);
      _loadAlerts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alert for ${alert.symbol} deleted')),
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

  void _showAddAlertDialog({String? presetSymbol, double? presetPrice}) {
    final symbolCtrl = TextEditingController(text: presetSymbol ?? '');
    final priceCtrl = TextEditingController(
      text: presetPrice != null ? presetPrice.toStringAsFixed(2) : '',
    );
    String condition = 'ABOVE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Price Alert'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: symbolCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Stock Symbol',
                        hintText: 'e.g. RELIANCE',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Target Price (₹)',
                        hintText: 'e.g. 3050.00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: condition,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ABOVE',
                          child: Text('Price crosses above (≥)'),
                        ),
                        DropdownMenuItem(
                          value: 'BELOW',
                          child: Text('Price drops below (≤)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            condition = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final sym = symbolCtrl.text.trim().toUpperCase();
                    final price = double.tryParse(priceCtrl.text.trim());
                    final messenger = ScaffoldMessenger.of(context);
                    if (sym.isEmpty || price == null || price <= 0) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Please enter a valid symbol and price')),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    try {
                      await AlertService.instance.createAlert(
                        symbol: sym,
                        targetPrice: price,
                        condition: condition,
                      );
                      _loadAlerts();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Alert created for $sym at ₹${price.toStringAsFixed(2)}')),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    }
                  },
                  child: const Text('Create Alert'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        actions: [
          IconButton(
            onPressed: () => _showAddAlertDialog(),
            icon: const Icon(Icons.add_alert_outlined),
            tooltip: 'Add Alert',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Price Alerts',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set alerts to get notified when a stock crosses your target threshold.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => _showAddAlertDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Alert'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      final isAbove = alert.condition == AlertCondition.above;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isAbove
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                child: Icon(
                                  isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isAbove ? Colors.green : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          alert.symbol,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (alert.isTriggered)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'TRIGGERED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Target: ${isAbove ? '≥' : '≤'} ₹${alert.targetPrice.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: alert.isActive,
                                onChanged: (val) => _toggleAlert(alert),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteAlert(alert),
                                tooltip: 'Delete Alert',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
