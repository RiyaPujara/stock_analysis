import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import '../../services/market_service.dart';
import '../../utils/app_theme.dart';

class WhatIfSimulatorScreen extends StatefulWidget {
  final String? initialSymbol;
  final double? initialPrice;

  final bool showAppBar;

  const WhatIfSimulatorScreen({
    super.key,
    this.initialSymbol,
    this.initialPrice,
    this.showAppBar = false,
  });

  @override
  State<WhatIfSimulatorScreen> createState() => _WhatIfSimulatorScreenState();
}

class _WhatIfSimulatorScreenState extends State<WhatIfSimulatorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _stockController;
  late final TextEditingController _currentPriceController;
  final TextEditingController _quantityController = TextEditingController(text: '10');
  final TextEditingController _expectedPriceController = TextEditingController(text: '3350.00');
  final TextEditingController _scenarioController = TextEditingController(
    text: 'Q3 earnings beat estimates by 22% with strong operating margin expansion across domestic businesses.',
  );

  bool _isFetchingLivePrice = false;
  bool _isAnalyzingWithGemini = false;
  GeminiWhatIfResult? _geminiResult;

  double? _futureValue;
  double? _profitLoss;
  double? _returnPercentage;

  final List<String> _popularIndianStocks = [
    'RELIANCE',
    'TCS',
    'HDFCBANK',
    'INFY',
    'TATAMOTORS',
    'ICICIBANK',
    'SBIN',
    'TATASTEEL',
    'ITC',
    'BHARTIARTL',
  ];

  final List<Map<String, String>> _scenarioPresets = [
    {
      'title': '📊 Q3 Profit Surge +25%',
      'prompt': 'Company reports blockbuster Q3 net profit surge of 25% YoY with record operating margins and raised guidance.',
    },
    {
      'title': '🏦 RBI Rate Cut 25bps',
      'prompt': 'Reserve Bank of India cuts repo rate by 25 bps, stimulating liquidity, credit growth, and equities multiple expansion.',
    },
    {
      'title': '🛢️ Crude Oil Spikes to \$100/bbl',
      'prompt': 'Geopolitical disruption pushes Brent crude to \$100/barrel, affecting input inflation, currency value, and transport costs.',
    },
    {
      'title': '🏗️ Govt Capex Boost +30%',
      'prompt': 'Union Budget allocates 30% higher capex outlay toward infrastructure, manufacturing, and indigenous supply chains.',
    },
    {
      'title': '🌐 Global Tech Slowdown',
      'prompt': 'US and European enterprise tech spending contracts by 10%, slowing order intake and lengthening conversion cycles.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.initialSymbol ?? 'RELIANCE');
    _currentPriceController = TextEditingController(
      text: widget.initialPrice != null ? widget.initialPrice!.toStringAsFixed(2) : '2945.50',
    );
    if (widget.initialPrice == null) {
      _fetchRealtimeQuote(_stockController.text);
    } else {
      _calculateFinancials();
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    _quantityController.dispose();
    _currentPriceController.dispose();
    _expectedPriceController.dispose();
    _scenarioController.dispose();
    super.dispose();
  }

  Future<void> _fetchRealtimeQuote(String symbol) async {
    if (symbol.trim().isEmpty) return;
    setState(() => _isFetchingLivePrice = true);

    try {
      final quote = await MarketService.instance.getRealtimeQuote(symbol.trim());
      final price = ((quote['currentPrice'] ?? 0.0) as num).toDouble();
      if (price > 0 && mounted) {
        setState(() {
          _currentPriceController.text = price.toStringAsFixed(2);
          final expected = (price * 1.12).toStringAsFixed(2);
          _expectedPriceController.text = expected;
        });
        _calculateFinancials();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isFetchingLivePrice = false);
    }
  }

  void _calculateFinancials() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final current = double.tryParse(_currentPriceController.text) ?? 0;
    final expected = double.tryParse(_expectedPriceController.text) ?? 0;

    if (qty > 0 && current > 0 && expected > 0) {
      final invested = qty * current;
      final futureVal = qty * expected;
      final pl = futureVal - invested;
      final retPct = invested > 0 ? (pl / invested) * 100 : 0.0;

      setState(() {
        _futureValue = futureVal;
        _profitLoss = pl;
        _returnPercentage = retPct;
      });
    }
  }

  Future<void> _runGeminiAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    _calculateFinancials();

    final symbol = _stockController.text.trim().toUpperCase();
    final currentPrice = double.tryParse(_currentPriceController.text) ?? 1000.0;
    final targetPrice = double.tryParse(_expectedPriceController.text);
    final quantity = double.tryParse(_quantityController.text);
    final scenario = _scenarioController.text.trim();

    setState(() => _isAnalyzingWithGemini = true);

    try {
      final result = await GeminiService.instance.analyzeWhatIf(
        symbol: symbol,
        currentPrice: currentPrice,
        scenario: scenario,
        targetPrice: targetPrice,
        quantity: quantity,
      );

      if (mounted) {
        setState(() {
          _geminiResult = result;
          // Optionally synchronize target with AI base projected price if desired
          if (result.baseProjectedPrice > 0) {
            _expectedPriceController.text = result.baseProjectedPrice.toStringAsFixed(2);
            _calculateFinancials();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Analysis note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzingWithGemini = false);
    }
  }

  void _openGeminiApiKeyDialog() {
    final keyController = TextEditingController(text: GeminiService.userApiKey ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key, color: AppTheme.primaryEmerald),
            SizedBox(width: 8),
            Text('Gemini AI API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API key to enable live cloud model inference, or leave empty to use our high-accuracy built-in macro simulation engine.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Google Gemini API Key',
                hintText: 'AIzaSy...',
                prefixIcon: Icon(Icons.security),
              ),
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
              GeminiService.userApiKey = keyController.text.trim();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gemini API key updated successfully!')),
              );
            },
            child: const Text('Save Key'),
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
              title: const Text('AI What-If Scenario Lab'),
              actions: [
                IconButton(
                  tooltip: 'Configure Gemini API Key',
                  onPressed: _openGeminiApiKeyDialog,
                  icon: const Icon(Icons.key_rounded),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero AI Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.aiGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Gemini AI Scenario Engine',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryEmerald.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'v1.5/2.0',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryEmerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Simulate macroeconomic events, rate changes, earnings surprises, and test the real-time valuation impact.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stock Selector & Ticker
              const Text(
                '1. Target Equity & Live Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Quick stock chip picker
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _popularIndianStocks.map((sym) {
                    final isSelected = _stockController.text.toUpperCase() == sym;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(sym),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryEmerald : null,
                        ),
                        onSelected: (val) {
                          if (val) {
                            _stockController.text = sym;
                            _fetchRealtimeQuote(sym);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _stockController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Stock Symbol',
                        hintText: 'e.g. RELIANCE',
                        prefixIcon: const Icon(Icons.business_rounded),
                        suffixIcon: _isFetchingLivePrice
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.refresh_rounded, size: 20),
                                tooltip: 'Fetch Real-Time Price via Indian-Stock-Market-API',
                                onPressed: () => _fetchRealtimeQuote(_stockController.text),
                              ),
                      ),
                      onChanged: (val) {
                        if (val.trim().length >= 3) {
                          _fetchRealtimeQuote(val);
                        }
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Shares Qty',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      onChanged: (_) => _calculateFinancials(),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currentPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Current Market Price (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      onChanged: (_) => _calculateFinancials(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _expectedPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Hypothetical Price (₹)',
                        prefixIcon: Icon(Icons.trending_up_rounded),
                      ),
                      onChanged: (_) => _calculateFinancials(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Scenario Selection
              const Text(
                '2. What-If Hypothesis / Catalysts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Scenario Preset Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _scenarioPresets.map((sc) {
                  return ActionChip(
                    label: Text(sc['title']!),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    backgroundColor: isDark ? const Color(0xFF161F32) : const Color(0xFFF1F5F9),
                    onPressed: () {
                      _scenarioController.text = sc['prompt']!;
                      _runGeminiAnalysis();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _scenarioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Hypothetical Scenario Description',
                  hintText: 'Type any custom event e.g. "What if crude drops to \$65 and USD/INR hits 84?"',
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a scenario' : null,
              ),

              const SizedBox(height: 22),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isAnalyzingWithGemini ? null : _runGeminiAnalysis,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.aiGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isAnalyzingWithGemini
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Gemini AI is analyzing scenario...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Analyze Scenario with Gemini AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Quantitative Calculation Card
              if (_futureValue != null) ...[
                const Text(
                  '3. Financial Impact Projection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Initial Investment', style: TextStyle(color: Color(0xFF94A3B8))),
                          Text(
                            '₹${((double.tryParse(_quantityController.text) ?? 1) * (double.tryParse(_currentPriceController.text) ?? 1)).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Projected Portfolio Value', style: TextStyle(color: Color(0xFF94A3B8))),
                          Text(
                            '₹${_futureValue!.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated P&L', style: TextStyle(color: Color(0xFF94A3B8))),
                          Row(
                            children: [
                              Icon(
                                _profitLoss! >= 0 ? Icons.trending_up : Icons.trending_down,
                                size: 18,
                                color: _profitLoss! >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_profitLoss! >= 0 ? '+' : ''}₹${_profitLoss!.toStringAsFixed(2)} (${_returnPercentage!.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _profitLoss! >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Gemini AI Detailed Insights
              if (_geminiResult != null) ...[
                Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: AppTheme.accentPurple),
                    const SizedBox(width: 8),
                    const Text(
                      'Gemini AI Strategic Intelligence',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _geminiResult!.sentiment == 'BULLISH'
                            ? AppTheme.successGreen.withValues(alpha: 0.15)
                            : _geminiResult!.sentiment == 'BEARISH'
                            ? AppTheme.dangerRed.withValues(alpha: 0.15)
                            : AppTheme.warningAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _geminiResult!.sentiment,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _geminiResult!.sentiment == 'BULLISH'
                              ? AppTheme.successGreen
                              : _geminiResult!.sentiment == 'BEARISH'
                              ? AppTheme.dangerRed
                              : AppTheme.warningAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // AI Executive Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF13192B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Scenario Probability:',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _geminiResult!.probability,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            'Confidence: ${_geminiResult!.confidenceScore}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryCyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _geminiResult!.executiveSummary,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      // Projected Price Range
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0C101A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _PriceColumn(
                              title: 'Bearish Case',
                              price: '₹${_geminiResult!.minProjectedPrice.toStringAsFixed(1)}',
                              color: AppTheme.dangerRed,
                            ),
                            _PriceColumn(
                              title: 'Base Case',
                              price: '₹${_geminiResult!.baseProjectedPrice.toStringAsFixed(1)}',
                              color: AppTheme.primaryCyan,
                            ),
                            _PriceColumn(
                              title: 'Bullish Case',
                              price: '₹${_geminiResult!.maxProjectedPrice.toStringAsFixed(1)}',
                              color: AppTheme.successGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Catalysts vs Risks
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Catalysts
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.successGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.arrow_upward_rounded, size: 16, color: AppTheme.successGreen),
                                SizedBox(width: 4),
                                Text(
                                  'Key Catalysts',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ..._geminiResult!.bullishCatalysts.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• $c', style: const TextStyle(fontSize: 12, height: 1.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Risks
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.dangerRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.dangerRed),
                                SizedBox(width: 4),
                                Text(
                                  'Risk Factors',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ..._geminiResult!.bearishRisks.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• $r', style: const TextStyle(fontSize: 12, height: 1.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Action Plan
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111E26) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.primaryEmerald.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppTheme.primaryEmerald),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Actionable Investor Playbook',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _geminiResult!.actionPlan,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Suggested SL: ₹${_geminiResult!.suggestedStopLoss.toStringAsFixed(1)} | Target: ₹${_geminiResult!.suggestedTarget.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  final String title;
  final String price;
  final Color color;

  const _PriceColumn({
    required this.title,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
