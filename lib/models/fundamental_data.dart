class FundamentalData {
  final String symbol;
  final double? marketCap; //Size of the company
  final double? peRatio; //Price compared with earnings
  final double? eps; //earning per share
  final double? roe; //return on equity-ROE tells how efficiently a company uses its shareholders' money to generate profit.
  final double? debtToEquity; //how much debt a company has compared with the money invested by its shareholders.(debt means borrowed money by company and equity means companies own money)
  final double? revenueGrowth;
  final double? profitGrowth;
  final double? dividendYield;

  FundamentalData({
    required this.symbol,
    this.marketCap,
    this.peRatio,
    this.eps,
    this.roe,
    this.debtToEquity,
    this.revenueGrowth,
    this.profitGrowth,
    this.dividendYield,
  });

  factory FundamentalData.fromJson(Map<String, dynamic> json) {
    return FundamentalData(
      symbol: json['symbol'],
      marketCap: (json['marketCap'] as num?)?.toDouble(),
      peRatio: (json['peRatio'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      roe: (json['roe'] as num?)?.toDouble(),
      debtToEquity: (json['debtToEquity'] as num?)?.toDouble(),
      revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble(),
      profitGrowth: (json['profitGrowth'] as num?)?.toDouble(),
      dividendYield: (json['dividendYield'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'marketCap': marketCap,
      'peRatio': peRatio,
      'eps': eps,
      'roe': roe,
      'debtToEquity': debtToEquity,
      'revenueGrowth': revenueGrowth,
      'profitGrowth': profitGrowth,
      'dividendYield': dividendYield,
    };
  }
}
