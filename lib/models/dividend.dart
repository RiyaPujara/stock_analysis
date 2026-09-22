class Dividend {
  final int id;
  final int portfolioId;
  final int stockId;
  final String symbol;
  final double quantity;
  final double dividendPerShare;
  final double totalAmount;
  final DateTime paymentDate;

  Dividend({
    required this.id,
    required this.portfolioId,
    required this.stockId,
    required this.symbol,
    required this.quantity,
    required this.dividendPerShare,
    required this.totalAmount,
    required this.paymentDate,
  });

  factory Dividend.fromJson(Map<String, dynamic> json) {
    return Dividend(
      id: json['id'],
      portfolioId: json['portfolioId'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      quantity: (json['quantity'] as num).toDouble(),
      dividendPerShare: (json['dividendPerShare'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolioId': portfolioId,
      'stockId': stockId,
      'symbol': symbol,
      'quantity': quantity,
      'dividendPerShare': dividendPerShare,
      'totalAmount': totalAmount,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}
