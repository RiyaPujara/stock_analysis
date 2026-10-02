import '../models/market_index.dart';
import '../models/historical_price.dart';
import '../models/fundamental_data.dart';
import '../models/technical_data.dart';
import 'api_client.dart';

class MarketService {
  static final MarketService instance = MarketService._internal();
  MarketService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<MarketIndex>> getIndices() async {
    try {
      final List data = await _api.get('/market/indices');
      return data.map((json) => MarketIndex.fromJson(json)).toList();
    } catch (_) {
      // Fallback to offline defaults
      return [
        MarketIndex(name: 'NIFTY 50', symbol: '^NSEI', currentValue: 25350.2, change: 181.5, changePercent: 0.72),
        MarketIndex(name: 'SENSEX', symbol: '^BSESN', currentValue: 82450.3, change: 475.2, changePercent: 0.58),
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getSectors() async {
    try {
      final List data = await _api.get('/market/sectors');
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [
        {'title': 'Banking', 'change': '+1.12%', 'isPositive': true},
        {'title': 'IT', 'change': '+0.84%', 'isPositive': true},
        {'title': 'Pharma', 'change': '-0.32%', 'isPositive': false},
        {'title': 'Auto', 'change': '+0.56%', 'isPositive': true},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> searchStocks({String? query}) async {
    try {
      final queryParams = query != null && query.isNotEmpty ? {'search': query} : null;
      final List data = await _api.get('/stocks', queryParams: queryParams);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      // Fallback
      return [
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
    }
  }

  Future<Map<String, dynamic>> getStockDetails(String symbol) async {
    try {
      final data = await _api.get('/stocks/$symbol');
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return {
        'symbol': symbol,
        'companyName': symbol == 'RELIANCE' ? 'Reliance Industries' : symbol,
        'currentPrice': 2945.50,
        'change': 36.40,
        'changePercent': 1.25,
        'open': 2910.00,
        'high': 2970.00,
        'low': 2895.00,
        'previousClose': 2909.10,
        'volume': 8420000,
        'week52High': 3024.90,
        'week52Low': 2221.00,
        'marketCap': '19.95T',
        'peRatio': 24.82,
        'dividendYield': 0.38,
        'eps': 118.62,
      };
    }
  }

  Future<List<HistoricalPrice>> getHistoricalPrices(String symbol, {String period = '1D'}) async {
    try {
      final List data = await _api.get('/stocks/$symbol/history', queryParams: {'period': period});
      return data.map((json) => HistoricalPrice.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<FundamentalData> getFundamentals(String symbol) async {
    try {
      final data = await _api.get('/stocks/$symbol/fundamentals');
      return FundamentalData.fromJson(data);
    } catch (_) {
      return FundamentalData(
        symbol: symbol,
        marketCap: 19950000,
        peRatio: 24.82,
        eps: 118.62,
        dividendYield: 0.38,
      );
    }
  }

  Future<TechnicalData> getTechnicals(String symbol) async {
    try {
      final data = await _api.get('/stocks/$symbol/technicals');
      return TechnicalData.fromJson(data);
    } catch (_) {
      return TechnicalData(symbol: symbol, rsi: 58.4, macd: 2.35, signal: 1.90);
    }
  }
}
