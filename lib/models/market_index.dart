class MarketIndex {
  final String name;
  final String symbol;
  final double currentValue;
  final double change;
  final double changePercent;

  MarketIndex({
    required this.name,
    required this.symbol,
    required this.currentValue,
    required this.change,
    required this.changePercent,
  });

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      name: json['name'],
      symbol: json['symbol'],
      currentValue: (json['currentValue'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'currentValue': currentValue,
      'change': change,
      'changePercent': changePercent,
    };
  }
}
