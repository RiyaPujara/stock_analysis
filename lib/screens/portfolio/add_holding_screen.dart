import 'package:flutter/material.dart';
import '../../services/portfolio_service.dart';

class AddHoldingScreen extends StatefulWidget {
  const AddHoldingScreen({super.key});

  @override
  State<AddHoldingScreen> createState() => _AddHoldingScreenState();
}

class _AddHoldingScreenState extends State<AddHoldingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stockController =
      TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _priceController =
      TextEditingController();

  String _selectedTransaction = 'Buy';
  String _selectedExchange = 'NSE';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _stockController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveHolding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final symbol = _stockController.text.trim().toUpperCase();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    setState(() {
      _isSaving = true;
    });

    try {
      await PortfolioService.instance.addHolding(
        symbol: symbol,
        quantity: quantity.toDouble(),
        purchasePrice: price,
        transactionType: _selectedTransaction.toLowerCase(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Holding $symbol ${_selectedTransaction.toLowerCase()}ed successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Holding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Add Stock to Portfolio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Enter the details of your stock transaction.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 28),

              // Stock
              Text(
                'Stock',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  hintText: 'Search stock or enter symbol',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a stock name or symbol';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // Exchange
              Text(
                'Exchange',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      title: 'NSE',
                      selected: _selectedExchange == 'NSE',
                      onTap: () {
                        setState(() {
                          _selectedExchange = 'NSE';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectionCard(
                      title: 'BSE',
                      selected: _selectedExchange == 'BSE',
                      onTap: () {
                        setState(() {
                          _selectedExchange = 'BSE';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Transaction Type
              Text(
                'Transaction Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      title: 'Buy',
                      icon: Icons.add_circle_outline,
                      selected: _selectedTransaction == 'Buy',
                      onTap: () {
                        setState(() {
                          _selectedTransaction = 'Buy';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectionCard(
                      title: 'Sell',
                      icon: Icons.remove_circle_outline,
                      selected: _selectedTransaction == 'Sell',
                      onTap: () {
                        setState(() {
                          _selectedTransaction = 'Sell';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Quantity
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of shares',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }

                  final quantity = int.tryParse(value);

                  if (quantity == null || quantity <= 0) {
                    return 'Enter a valid quantity';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              // Purchase Price
              Text(
                'Price per Share',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter price per share',
                  prefixText: '₹ ',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }

                  final price = double.tryParse(value);

                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Estimated Investment
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Investment',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                            Builder(
                              builder: (context) {
                                final q = double.tryParse(_quantityController.text.trim()) ?? 0.0;
                                final p = double.tryParse(_priceController.text.trim()) ?? 0.0;
                                final est = q * p;
                                return Text(
                                  est > 0 ? '₹${est.toStringAsFixed(2)}' : 'Enter quantity and price',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveHolding,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Add to Portfolio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
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

// Selection Card
class _SelectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
