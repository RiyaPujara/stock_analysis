class TechnicalData {
  final String symbol;
  final double? rsi; //Relative Strength Index-It measures the strength of recent price movements on a scale from 0 to 100.Below 30=	Potentially oversold, Around 50	= Neutral ,Above 70=	Potentially overbought
  final double? macd; //Moving Average Convergence Divergence=>It compares different moving averages to help analyze price momentum and trend changes.
  final double? signal; //This is the MACD signal line.It is a moving average of the MACD value and is commonly used to identify potential changes in momentum.Example:MACD   = 2.35,Signal = 1.90
  final double? sma20; //Simple Moving Average - the average closing price over the last 20 trading periods.
  final double? sma50; //Simple Moving Average over the last 50 trading periods.
  final double? ema20; //Exponential Moving Average - 20-period average with more weight on recent prices

  TechnicalData({
    required this.symbol,
    this.rsi,
    this.macd,
    this.signal,
    this.sma20,
    this.sma50,
    this.ema20,
  });

  factory TechnicalData.fromJson(Map<String, dynamic> json) {
    return TechnicalData(
      symbol: json['symbol'],
      rsi: (json['rsi'] as num?)?.toDouble(),
      macd: (json['macd'] as num?)?.toDouble(),
      signal: (json['signal'] as num?)?.toDouble(),
      sma20: (json['sma20'] as num?)?.toDouble(),
      sma50: (json['sma50'] as num?)?.toDouble(),
      ema20: (json['ema20'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'rsi': rsi,
      'macd': macd,
      'signal': signal,
      'sma20': sma20,
      'sma50': sma50,
      'ema20': ema20,
    };
  }
}
