enum TransactionType { buy, sell }

class Transaction {
  final int id;
  final int portfolioId;
  final int stockId;
  final String symbol;
  final TransactionType type;
  final double quantity;
  final double price;
  final double brokerage;
  final double taxes;
  final double totalAmount;
  final DateTime transactionDate;

  Transaction({
    required this.id,
    required this.portfolioId,
    required this.stockId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.brokerage,
    required this.taxes,
    required this.totalAmount,
    required this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      portfolioId: json['portfolioId'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      type: json['type'] == 'BUY' ? TransactionType.buy : TransactionType.sell,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      brokerage: (json['brokerage'] as num).toDouble(),
      taxes: (json['taxes'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolioId': portfolioId,
      'stockId': stockId,
      'symbol': symbol,
      'type': type == TransactionType.buy ? 'BUY' : 'SELL',
      'quantity': quantity,
      'price': price,
      'brokerage': brokerage, //platform charge
      'taxes': taxes,
      'totalAmount': totalAmount,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }
}
