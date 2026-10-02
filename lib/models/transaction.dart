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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      portfolioId: json['portfolioId'] is int
          ? json['portfolioId']
          : int.tryParse(json['portfolioId']?.toString() ?? '1') ?? 1,
      stockId: json['stockId'] is int
          ? json['stockId']
          : int.tryParse(json['stockId']?.toString() ?? '1') ?? 1,
      symbol: json['symbol'] ?? '',
      type: (json['type']?.toString().toUpperCase() == 'SELL')
          ? TransactionType.sell
          : TransactionType.buy,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      brokerage: (json['brokerage'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
