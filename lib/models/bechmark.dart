class Benchmark {
  final int id;
  final String name;
  final String symbol;
  final String exchange;

  Benchmark({
    required this.id,
    required this.name,
    required this.symbol,
    required this.exchange,
  });

  factory Benchmark.fromJson(Map<String, dynamic> json) {
    return Benchmark(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      exchange: json['exchange'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'symbol': symbol, 'exchange': exchange};
  }
}
