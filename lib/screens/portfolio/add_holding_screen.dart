import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _stockController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveHolding() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Holding added successfully'),
      ),
    );

    Navigator.pop(context);
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
                            const SizedBox(height: 5),
                            Text(
                              'Enter quantity and price',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                  onPressed: _saveHolding,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Add to Portfolio',
                    style: TextStyle(
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
