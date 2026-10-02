import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stock_analysis/main.dart';
import 'package:stock_analysis/models/price_alert.dart';
import 'package:stock_analysis/models/holding.dart';
import 'package:stock_analysis/models/market_index.dart';
import 'package:stock_analysis/models/watchlist.dart';
import 'package:stock_analysis/screens/alerts/alerts_screen.dart';
import 'package:stock_analysis/screens/notifications/notification_screen.dart';
import 'package:stock_analysis/screens/watchlist/watchlist_screen.dart';

void main() {
  group('Stock Analyzer App Smoke & Unit Tests', () {
    testWidgets('App launches with LoginScreen and theme builder', (WidgetTester tester) async {
      await tester.pumpWidget(const StockPortfolioApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    test('PriceAlert model serialization & deserialization', () {
      final alertJson = {
        'id': '65f1234567890abcdef12345',
        'userId': '65f1234567890abcdef12346',
        'stockId': '65f1234567890abcdef12347',
        'symbol': 'RELIANCE',
        'targetPrice': 3200.50,
        'condition': 'ABOVE',
        'isActive': true,
        'isTriggered': false,
        'createdAt': '2026-09-30T10:00:00.000Z',
      };

      final alert = PriceAlert.fromJson(alertJson);
      expect(alert.symbol, 'RELIANCE');
      expect(alert.targetPrice, 3200.50);
      expect(alert.condition, AlertCondition.above);
      expect(alert.isActive, true);
      expect(alert.isTriggered, false);
      expect(alert.alertId, '65f1234567890abcdef12345');

      final outputJson = alert.toJson();
      expect(outputJson['symbol'], 'RELIANCE');
      expect(outputJson['condition'], 'ABOVE');
      expect(outputJson['isActive'], true);
    });

    test('Holding model calculated getters and helpers', () {
      final holdingJson = {
        'id': '65fholding123',
        'portfolioId': '65fport123',
        'stockId': '65fstock123',
        'symbol': 'TCS',
        'companyName': 'Tata Consultancy Services',
        'quantity': 10,
        'averageBuyPrice': 4000.0,
        'currentPrice': 4200.0,
        'currentValue': 42000.0,
        'gain': 2000.0,
        'gainPercent': 5.0,
      };

      final holding = Holding.fromJson(holdingJson);
      expect(holding.stockSymbol, 'TCS');
      expect(holding.stockName, 'Tata Consultancy Services');
      expect(holding.totalValue, 42000.0);
      expect(holding.gainLoss, 2000.0);
      expect(holding.gainLossPercentage, 5.0);
    });

    test('MarketIndex model values', () {
      final index = MarketIndex(
        name: 'NIFTY 50',
        symbol: '^NSEI',
        currentValue: 25350.20,
        change: 181.50,
        changePercent: 0.72,
      );

      expect(index.name, 'NIFTY 50');
      expect(index.value, 25350.20);
      expect(index.changePercent, 0.72);
    });

    test('WatchlistItem model parsing', () {
      final item = WatchlistItem(
        id: 1,
        userId: 1,
        stockId: 1,
        symbol: 'INFY',
        companyName: 'Infosys',
      );

      expect(item.symbol, 'INFY');
      expect(item.companyName, 'Infosys');
    });

    testWidgets('NotificationsScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('WatchlistScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WatchlistScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('AlertsScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlertsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price Alerts'), findsOneWidget);
    });
  });
}
