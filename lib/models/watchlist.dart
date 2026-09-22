class WatchlistItem {
  final int id;
  final int userId;
  final int stockId;
  final String symbol;
  final String companyName;
  final DateTime? addedAt;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.stockId,
    required this.symbol,
    required this.companyName,
    this.addedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'],
      userId: json['userId'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      companyName: json['companyName'],
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stockId': stockId,
      'symbol': symbol,
      'companyName': companyName,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}
