import 'api_client.dart';

class WatchlistService {
  static final WatchlistService instance = WatchlistService._internal();
  WatchlistService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getWatchlist() async {
    try {
      final List data = await _api.get('/watchlist');
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
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

  Future<void> addToWatchlist(String symbol) async {
    await _api.post('/watchlist', body: {'symbol': symbol.toUpperCase()});
  }

  Future<void> removeFromWatchlist(String symbolOrId) async {
    await _api.delete('/watchlist/$symbolOrId');
  }
}
