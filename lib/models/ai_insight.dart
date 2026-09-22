enum AIInsightType {
  portfolioAnalysis,
  stockAnalysis,
  riskExplanation,
  marketSummary,
  stockScreener,
}

class AIInsight {
  final int id;
  final int? userId;
  final int? portfolioId;
  final AIInsightType type;
  final String title;
  final String content;
  final DateTime generatedAt;

  AIInsight({
    required this.id,
    this.userId,
    this.portfolioId,
    required this.type,
    required this.title,
    required this.content,
    required this.generatedAt,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'],
      userId: json['userId'],
      portfolioId: json['portfolioId'],
      type: _parseType(json['type']),
      title: json['title'],
      content: json['content'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
  //helper function that converts a String received from the backend into the corresponding Dart enum value.
  static AIInsightType _parseType(String type) {
    switch (type) {
      case 'STOCK_ANALYSIS':
        return AIInsightType.stockAnalysis;
      case 'RISK_EXPLANATION':
        return AIInsightType.riskExplanation;
      case 'MARKET_SUMMARY':
        return AIInsightType.marketSummary;
      case 'STOCK_SCREENER':
        return AIInsightType.stockScreener;
      default:
        return AIInsightType.portfolioAnalysis;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'portfolioId': portfolioId,
      'type': type.name,
      'title': title,
      'content': content,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
