import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import yfinance as yf

app = Flask(__name__)
CORS(app)

POPULAR_STOCKS = [
    {"symbol": "RELIANCE.NS", "name": "Reliance Industries Ltd", "sector": "Energy"},
    {"symbol": "TCS.NS", "name": "Tata Consultancy Services", "sector": "Technology"},
    {"symbol": "HDFCBANK.NS", "name": "HDFC Bank Ltd", "sector": "Financial Services"},
    {"symbol": "INFY.NS", "name": "Infosys Ltd", "sector": "Technology"},
    {"symbol": "ICICIBANK.NS", "name": "ICICI Bank Ltd", "sector": "Financial Services"},
    {"symbol": "BHARTIARTL.NS", "name": "Bharti Airtel Ltd", "sector": "Telecom"},
    {"symbol": "SBIN.NS", "name": "State Bank of India", "sector": "Banking"},
    {"symbol": "LICI.NS", "name": "Life Insurance Corp of India", "sector": "Insurance"},
    {"symbol": "ITC.NS", "name": "ITC Ltd", "sector": "Consumer Goods"},
    {"symbol": "TATAMOTORS.NS", "name": "Tata Motors Ltd", "sector": "Automobile"},
    {"symbol": "TATASTEEL.NS", "name": "Tata Steel Ltd", "sector": "Metals"},
    {"symbol": "WIPRO.NS", "name": "Wipro Ltd", "sector": "Technology"},
    {"symbol": "HINDUNILVR.NS", "name": "Hindustan Unilever Ltd", "sector": "FMCG"},
    {"symbol": "BAJFINANCE.NS", "name": "Bajaj Finance Ltd", "sector": "Financial Services"},
    {"symbol": "MARUTI.NS", "name": "Maruti Suzuki India", "sector": "Automobile"},
]

def format_symbol(sym: str) -> str:
    sym = sym.strip().upper()
    if not (sym.endswith('.NS') or sym.endswith('.BO')):
        sym += '.NS'
    return sym

def fetch_single_stock(sym: str, res_format: str = "num"):
    formatted_sym = format_symbol(sym)
    ticker = yf.Ticker(formatted_sym)
    info = ticker.info or {}
    
    current_price = info.get("currentPrice") or info.get("regularMarketPrice") or 0.0
    previous_close = info.get("previousClose") or info.get("regularMarketPreviousClose") or current_price
    
    change = current_price - previous_close if previous_close else 0.0
    change_percent = (change / previous_close * 100) if previous_close else 0.0

    if res_format == "val":
        return {
            "symbol": formatted_sym,
            "companyName": info.get("shortName") or info.get("longName") or sym,
            "currentPrice": {"value": round(current_price, 2), "unit": "INR"},
            "change": {"value": round(change, 2), "unit": "INR"},
            "changePercent": {"value": round(change_percent, 2), "unit": "%"},
            "dayHigh": {"value": round(info.get("dayHigh", current_price), 2), "unit": "INR"},
            "dayLow": {"value": round(info.get("dayLow", current_price), 2), "unit": "INR"},
            "fiftyTwoWeekHigh": {"value": round(info.get("fiftyTwoWeekHigh", 0.0), 2), "unit": "INR"},
            "fiftyTwoWeekLow": {"value": round(info.get("fiftyTwoWeekLow", 0.0), 2), "unit": "INR"},
            "volume": {"value": info.get("volume", 0), "unit": "shares"},
            "marketCap": {"value": info.get("marketCap", 0), "unit": "INR"},
            "peRatio": {"value": round(info.get("trailingPE", 0.0), 2), "unit": "x"},
            "sector": info.get("sector", "N/A"),
            "exchange": "NSE" if formatted_sym.endswith('.NS') else "BSE",
        }

    return {
        "symbol": formatted_sym.replace(".NS", "").replace(".BO", ""),
        "fullSymbol": formatted_sym,
        "companyName": info.get("shortName") or info.get("longName") or sym,
        "currentPrice": round(float(current_price), 2),
        "change": round(float(change), 2),
        "changePercent": round(float(change_percent), 2),
        "dayHigh": round(float(info.get("dayHigh", current_price)), 2),
        "dayLow": round(float(info.get("dayLow", current_price)), 2),
        "fiftyTwoWeekHigh": round(float(info.get("fiftyTwoWeekHigh", 0.0)), 2),
        "fiftyTwoWeekLow": round(float(info.get("fiftyTwoWeekLow", 0.0)), 2),
        "volume": int(info.get("volume", 0)),
        "marketCap": int(info.get("marketCap", 0)),
        "peRatio": round(float(info.get("trailingPE", 0.0)), 2),
        "dividendYield": round(float(info.get("dividendYield", 0.0) * 100), 2) if info.get("dividendYield") else 0.0,
        "sector": info.get("sector", "Diversified"),
        "exchange": "NSE" if formatted_sym.endswith('.NS') else "BSE",
    }

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "name": "Indian Stock Market API",
        "description": "Real-time stock data API for NSE & BSE stocks powered by Yahoo Finance",
        "reference": "https://github.com/0xramm/Indian-Stock-Market-API",
        "endpoints": [
            "GET /stock?symbol={SYMBOL}&res={num|val}",
            "GET /stock/list?symbols={SYM1,SYM2}&res={num|val}",
            "GET /search?q={query}",
            "GET /indices",
            "GET /symbols"
        ]
    })

@app.route('/stock', methods=['GET'])
def get_stock():
    symbol = request.args.get('symbol')
    if not symbol:
        return jsonify({"error": "symbol parameter is required"}), 400
    res_format = request.args.get('res', 'num')
    try:
        data = fetch_single_stock(symbol, res_format)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/stock/list', methods=['GET'])
def get_stock_list():
    symbols_param = request.args.get('symbols')
    if not symbols_param:
        return jsonify({"error": "symbols parameter is required"}), 400
    res_format = request.args.get('res', 'num')
    symbols = [s.strip() for s in symbols_param.split(',') if s.strip()]
    results = []
    for s in symbols:
        try:
            results.append(fetch_single_stock(s, res_format))
        except Exception as e:
            results.append({"symbol": s, "error": str(e)})
    return jsonify(results)

@app.route('/indices', methods=['GET'])
def get_indices():
    indices_map = [
        {"name": "NIFTY 50", "ticker": "^NSEI"},
        {"name": "SENSEX", "ticker": "^BSESN"},
        {"name": "NIFTY BANK", "ticker": "^NSEBANK"},
        {"name": "NIFTY IT", "ticker": "^CNXIT"},
    ]
    results = []
    for idx in indices_map:
        try:
            t = yf.Ticker(idx["ticker"])
            info = t.info or {}
            price = info.get("regularMarketPrice") or info.get("currentPrice") or 0.0
            prev = info.get("regularMarketPreviousClose") or info.get("previousClose") or price
            chg = price - prev if prev else 0.0
            chg_pct = (chg / prev * 100) if prev else 0.0
            results.append({
                "name": idx["name"],
                "symbol": idx["ticker"],
                "currentValue": round(price, 2),
                "change": round(chg, 2),
                "changePercent": round(chg_pct, 2)
            })
        except Exception:
            pass
    return jsonify(results)

@app.route('/search', methods=['GET'])
def search_stocks():
    query = request.args.get('q', '').strip().lower()
    if not query:
        return jsonify(POPULAR_STOCKS)
    matches = [
        s for s in POPULAR_STOCKS 
        if query in s['symbol'].lower() or query in s['name'].lower() or query in s['sector'].lower()
    ]
    return jsonify(matches)

@app.route('/symbols', methods=['GET'])
def list_symbols():
    return jsonify(POPULAR_STOCKS)

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    print(f"[+] Indian Stock Market API running on http://127.0.0.1:{port}")
    app.run(host='0.0.0.0', port=port, debug=False)
