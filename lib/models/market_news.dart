class MarketNews {
  final int id;
  final String title;
  final String summary;
  final String source;
  final String url;
  final DateTime publishedAt;
  final String? sentiment;
  final String? relatedSymbol;

  MarketNews({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.sentiment,
    this.relatedSymbol,
  });

  factory MarketNews.fromJson(Map<String, dynamic> json) {
    return MarketNews(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      source: json['source'],
      url: json['url'],
      publishedAt: DateTime.parse(json['publishedAt']),
      sentiment: json['sentiment'],
      relatedSymbol: json['relatedSymbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'source': source,
      'url': url,
      'publishedAt': publishedAt.toIso8601String(),
      'sentiment': sentiment,
      'relatedSymbol': relatedSymbol,
    };
  }
}
