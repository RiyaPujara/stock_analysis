class Holding {
  final int id;
  final int portfolioId;
  final int stockId;
  final String symbol;
  final String? companyName;
  final double quantity;
  final double averageBuyPrice;

  Holding({
    required this.id,
    required this.portfolioId,
    required this.stockId,
    required this.symbol,
    this.companyName,
    required this.quantity,
    required this.averageBuyPrice,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'],
      portfolioId: json['portfolioId'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      companyName: json['companyName'],
      quantity: (json['quantity'] as num).toDouble(),
      averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolioId': portfolioId,
      'stockId': stockId,
      'symbol': symbol,
      'companyName': companyName,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
    };
  }
}
