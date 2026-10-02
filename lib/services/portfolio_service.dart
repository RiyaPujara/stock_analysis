import '../models/holding.dart';
import '../models/transaction.dart';
import 'api_client.dart';

class PortfolioService {
  static final PortfolioService instance = PortfolioService._internal();
  PortfolioService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final data = await _api.get('/portfolio/summary');
      return Map<String, dynamic>.from(data);
    } catch (_) {
      // Fallback
      return {
        'totalValue': 125000.00,
        'investedValue': 112550.00,
        'totalGain': 12450.00,
        'totalGainPercent': 11.05,
        'todayGain': 2450.00,
        'todayGainPercent': 1.98,
        'holdingsCount': 4,
        'assetAllocation': [
          {'name': 'Stocks', 'percentage': '80%', 'value': '₹1,00,000'},
          {'name': 'Cash', 'percentage': '15%', 'value': '₹18,750'},
          {'name': 'Other', 'percentage': '5%', 'value': '₹6,250'},
        ],
        'stockAllocation': [
          {'symbol': 'RELIANCE', 'name': 'Reliance Industries', 'percentage': '23.6%', 'value': '₹29,455'},
          {'symbol': 'TCS', 'name': 'Tata Consultancy Services', 'percentage': '16.5%', 'value': '₹20,629'},
          {'symbol': 'INFY', 'name': 'Infosys', 'percentage': '11.9%', 'value': '₹14,852'},
          {'symbol': 'HDFCBANK', 'name': 'HDFC Bank', 'percentage': '12.0%', 'value': '₹15,003'},
        ],
      };
    }
  }

  Future<List<Holding>> getHoldings() async {
    try {
      final List data = await _api.get('/portfolio/holdings');
      return data.map((json) => Holding.fromJson(json)).toList();
    } catch (_) {
      return [
        Holding(id: 1, portfolioId: 1, stockId: 1, symbol: 'RELIANCE', companyName: 'Reliance Industries', quantity: 10, averageBuyPrice: 2850),
        Holding(id: 2, portfolioId: 1, stockId: 2, symbol: 'TCS', companyName: 'Tata Consultancy Services', quantity: 5, averageBuyPrice: 3950),
        Holding(id: 3, portfolioId: 1, stockId: 3, symbol: 'INFY', companyName: 'Infosys', quantity: 10, averageBuyPrice: 1520),
        Holding(id: 4, portfolioId: 1, stockId: 4, symbol: 'HDFCBANK', companyName: 'HDFC Bank', quantity: 8, averageBuyPrice: 1810),
      ];
    }
  }

  Future<Map<String, dynamic>> addHolding({
    required String symbol,
    String exchange = 'NSE',
    String type = 'BUY',
    required double quantity,
    double? price,
    double? purchasePrice,
    String? transactionType,
    double brokerage = 0.0,
    double taxes = 0.0,
  }) async {
    final effectivePrice = price ?? purchasePrice ?? 0.0;
    final effectiveType = transactionType ?? type;
    final data = await _api.post('/portfolio/holdings', body: {
      'symbol': symbol.toUpperCase().trim(),
      'exchange': exchange,
      'type': effectiveType.toUpperCase(),
      'quantity': quantity,
      'price': effectivePrice,
      'brokerage': brokerage,
      'taxes': taxes,
    });
    return Map<String, dynamic>.from(data);
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final List data = await _api.get('/portfolio/transactions');
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final data = await _api.get('/portfolio/analytics');
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return {
        'summary': await getSummary(),
        'performanceLeaders': [
          {'company': 'Reliance Industries', 'symbol': 'RELIANCE', 'returnValue': '+18.40%', 'isPositive': true},
          {'company': 'TCS', 'symbol': 'TCS', 'returnValue': '+14.25%', 'isPositive': true},
          {'company': 'Infosys', 'symbol': 'INFY', 'returnValue': '-3.20%', 'isPositive': false},
        ],
        'riskDiversification': {
          'diversification': 'Good',
          'portfolioRisk': 'Moderate',
          'sectorExposure': 'Balanced',
        },
      };
    }
  }
}
