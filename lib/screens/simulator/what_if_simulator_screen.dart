import 'package:flutter/material.dart';

class WhatIfSimulatorScreen extends StatefulWidget {
  const WhatIfSimulatorScreen({super.key});

  @override
  State<WhatIfSimulatorScreen> createState() =>
      _WhatIfSimulatorScreenState();
}

class _WhatIfSimulatorScreenState extends State<WhatIfSimulatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _stockController = TextEditingController(text: 'RELIANCE');
  final _quantityController = TextEditingController(text: '10');
  final _currentPriceController =
      TextEditingController(text: '2945.50');
  final _expectedPriceController =
      TextEditingController(text: '3300');

  double? _futureValue;
  double? _profitLoss;
  double? _returnPercentage;

  @override
  void dispose() {
    _stockController.dispose();
    _quantityController.dispose();
    _currentPriceController.dispose();
    _expectedPriceController.dispose();
    super.dispose();
  }

  void _simulate() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final quantity = double.parse(_quantityController.text);
  final currentPrice = double.parse(_currentPriceController.text);
  final expectedPrice = double.parse(_expectedPriceController.text);

  final investedValue = quantity * currentPrice;
  final futureValue = quantity * expectedPrice;
  final profitLoss = futureValue - investedValue;

  final double returnPercentage = investedValue == 0.0
      ? 0.0
      : (profitLoss / investedValue) * 100.0;

  setState(() {
    _futureValue = futureValue;
    _profitLoss = profitLoss;
    _returnPercentage = returnPercentage;
  });
}

  void _clearSimulation() {
    setState(() {
      _futureValue = null;
      _profitLoss = null;
      _returnPercentage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _futureValue != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What-If Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          Icons.auto_awesome,
                          color:
                              Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI What-If Simulator',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Explore a hypothetical stock price '
                              'scenario and see the potential impact '
                              'on your investment.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Scenario Details',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _stockController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Stock Symbol',
                  hintText: 'e.g. RELIANCE',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a stock symbol';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Number of shares',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final quantity = double.tryParse(
                    value ?? '',
                  );

                  if (quantity == null || quantity <= 0) {
                    return 'Enter a valid quantity';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _currentPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Current Price',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(
                    value ?? '',
                  );

                  if (price == null || price <= 0) {
                    return 'Enter a valid current price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _expectedPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Expected Future Price',
                  hintText: 'Your hypothetical price',
                  prefixIcon: Icon(Icons.trending_up),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(
                    value ?? '',
                  );

                  if (price == null || price <= 0) {
                    return 'Enter a valid expected price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _simulate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'Run Simulation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (hasResult) ...[
                const SizedBox(height: 32),

                Text(
                  'Simulation Result',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ResultRow(
                          title: 'Stock',
                          value:
                              _stockController.text.toUpperCase(),
                        ),
                        _ResultRow(
                          title: 'Current Investment',
                          value:
                              '₹${(_getCurrentInvestment()).toStringAsFixed(2)}',
                        ),
                        _ResultRow(
                          title: 'Estimated Future Value',
                          value:
                              '₹${_futureValue!.toStringAsFixed(2)}',
                        ),
                        _ResultRow(
                          title: 'Potential Profit / Loss',
                          value:
                              '₹${_profitLoss!.toStringAsFixed(2)}',
                          valueColor: _profitLoss! >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        _ResultRow(
                          title: 'Expected Return',
                          value:
                              '${_returnPercentage!.toStringAsFixed(2)}%',
                          valueColor: _returnPercentage! >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          _profitLoss! >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 32,
                          color: _profitLoss! >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _profitLoss! >= 0
                                ? 'In this hypothetical scenario, '
                                  'the investment could generate a '
                                  'potential gain of '
                                  '₹${_profitLoss!.toStringAsFixed(2)}.'
                                : 'In this hypothetical scenario, '
                                  'the investment could result in a '
                                  'potential loss of '
                                  '₹${_profitLoss!.abs().toStringAsFixed(2)}.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _clearSimulation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear Simulation'),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Text(
                'Note: This simulator uses hypothetical values '
                'entered by you. It does not predict actual future '
                'stock prices or investment returns.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  double _getCurrentInvestment() {
    final quantity = double.parse(_quantityController.text);
    final currentPrice =
        double.parse(_currentPriceController.text);

    return quantity * currentPrice;
  }
}

class _ResultRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _ResultRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
