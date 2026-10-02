class Holding {
  final int id;
  final String? holdingId;
  final int portfolioId;
  final int stockId;
  final String symbol;
  final String? companyName;
  final double quantity;
  final double averageBuyPrice;
  final double currentPrice;
  final double currentValue;
  final double gain;
  final double gainPercent;
  final double allocation;

  Holding({
    required this.id,
    this.holdingId,
    required this.portfolioId,
    required this.stockId,
    required this.symbol,
    this.companyName,
    required this.quantity,
    required this.averageBuyPrice,
    this.currentPrice = 0.0,
    this.currentValue = 0.0,
    this.gain = 0.0,
    this.gainPercent = 0.0,
    this.allocation = 0.0,
  });

  String get stockName => companyName ?? symbol;
  String get stockSymbol => symbol;
  double get totalValue =>
      currentValue > 0 ? currentValue : (quantity * (currentPrice > 0 ? currentPrice : averageBuyPrice));
  double get gainLoss => gain;
  double get gainLossPercentage => gainPercent;
  double get allocationPercent => allocation;

  factory Holding.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toDouble() ?? 0.0;
    final avg = (json['averageBuyPrice'] as num?)?.toDouble() ?? 0.0;
    final curPrice = (json['currentPrice'] as num?)?.toDouble() ?? avg;
    final curVal = (json['currentValue'] as num?)?.toDouble() ?? (qty * curPrice);
    final g = (json['gain'] as num?)?.toDouble() ?? (curVal - (qty * avg));
    final gPct = (json['gainPercent'] as num?)?.toDouble() ??
        ((qty * avg) > 0 ? (g / (qty * avg)) * 100 : 0.0);

    return Holding(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      holdingId: json['id']?.toString(),
      portfolioId: json['portfolioId'] is int
          ? json['portfolioId']
          : int.tryParse(json['portfolioId']?.toString() ?? '1') ?? 1,
      stockId: json['stockId'] is int
          ? json['stockId']
          : int.tryParse(json['stockId']?.toString() ?? '1') ?? 1,
      symbol: json['symbol'] ?? '',
      companyName: json['companyName'] ?? json['stockName'],
      quantity: qty,
      averageBuyPrice: avg,
      currentPrice: curPrice,
      currentValue: curVal,
      gain: g,
      gainPercent: gPct,
      allocation: (json['allocationPercent'] as num?)?.toDouble() ??
          (json['allocation'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': holdingId ?? id,
      'portfolioId': portfolioId,
      'stockId': stockId,
      'symbol': symbol,
      'companyName': companyName,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
      'currentPrice': currentPrice,
      'currentValue': currentValue,
      'gain': gain,
      'gainPercent': gainPercent,
    };
  }
}
