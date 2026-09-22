enum AlertCondition { above, below }

class PriceAlert {
  final int id;
  final int userId;
  final int stockId;
  final String symbol;
  final double targetPrice;
  final AlertCondition condition;
  final bool isTriggered;
  final DateTime? createdAt;

  PriceAlert({
    required this.id,
    required this.userId,
    required this.stockId,
    required this.symbol,
    required this.targetPrice,
    required this.condition,
    required this.isTriggered,
    this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'],
      userId: json['userId'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      targetPrice: (json['targetPrice'] as num).toDouble(),
      condition: json['condition'] == 'ABOVE'
          ? AlertCondition.above
          : AlertCondition.below,
      isTriggered: json['isTriggered'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stockId': stockId,
      'symbol': symbol,
      'targetPrice': targetPrice,
      'condition': condition == AlertCondition.above ? 'ABOVE' : 'BELOW',
      'isTriggered': isTriggered,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
