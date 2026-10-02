enum AlertCondition { above, below }

class PriceAlert {
  final int id;
  final String? alertId;
  final int userId;
  final int stockId;
  final String symbol;
  final double targetPrice;
  final AlertCondition condition;
  final bool isActive;
  final bool isTriggered;
  final DateTime? createdAt;

  PriceAlert({
    required this.id,
    this.alertId,
    required this.userId,
    required this.stockId,
    required this.symbol,
    required this.targetPrice,
    required this.condition,
    this.isActive = true,
    required this.isTriggered,
    this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      alertId: json['id']?.toString(),
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '1') ?? 1,
      stockId: json['stockId'] is int
          ? json['stockId']
          : int.tryParse(json['stockId']?.toString() ?? '1') ?? 1,
      symbol: json['symbol'] ?? '',
      targetPrice: (json['targetPrice'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] == 'ABOVE'
          ? AlertCondition.above
          : AlertCondition.below,
      isActive: json['isActive'] ?? true,
      isTriggered: json['isTriggered'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': alertId ?? id,
      'userId': userId,
      'stockId': stockId,
      'symbol': symbol,
      'targetPrice': targetPrice,
      'condition': condition == AlertCondition.above ? 'ABOVE' : 'BELOW',
      'isActive': isActive,
      'isTriggered': isTriggered,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
