import 'api_client.dart';
import '../models/price_alert.dart';

class AlertService {
  static final AlertService instance = AlertService._internal();
  AlertService._internal();

  final ApiClient _api = ApiClient.instance;

  Future<List<PriceAlert>> getAlerts() async {
    try {
      final List data = await _api.get('/alerts');
      return data
          .map((e) => PriceAlert.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [
        PriceAlert(
          id: 1,
          alertId: 'mock_1',
          userId: 1,
          stockId: 1,
          symbol: 'RELIANCE',
          targetPrice: 3100.0,
          condition: AlertCondition.above,
          isActive: true,
          isTriggered: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PriceAlert(
          id: 2,
          alertId: 'mock_2',
          userId: 1,
          stockId: 2,
          symbol: 'TCS',
          targetPrice: 4000.0,
          condition: AlertCondition.below,
          isActive: true,
          isTriggered: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
  }

  Future<PriceAlert> createAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    final res = await _api.post('/alerts', body: {
      'symbol': symbol.toUpperCase(),
      'targetPrice': targetPrice,
      'condition': condition.toUpperCase(),
    });
    return PriceAlert.fromJson(Map<String, dynamic>.from(res));
  }

  Future<PriceAlert?> toggleAlert(String alertId) async {
    try {
      final res = await _api.patch('/alerts/$alertId/toggle');
      return PriceAlert.fromJson(Map<String, dynamic>.from(res));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAlert(String alertId) async {
    await _api.delete('/alerts/$alertId');
  }
}
