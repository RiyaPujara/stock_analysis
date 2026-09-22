class Stock {
  final int id;
  final String symbol;
  final String companyName;
  final String exchange;
  final String? sector;
  final String? industry;
  final String? description;

  Stock({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    this.sector,
    this.industry,
    this.description,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      symbol: json['symbol'],
      companyName: json['companyName'],
      exchange: json['exchange'],
      sector: json['sector'],
      industry: json['industry'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'companyName': companyName,
      'exchange': exchange,
      'sector': sector,
      'industry': industry,
      'description': description,
    };
  }
}
