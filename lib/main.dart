import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';

void main() {
  runApp(const StockPortfolioApp());
}

class StockPortfolioApp extends StatelessWidget {
  const StockPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Stock Portfolio & Market Analyzer',

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),

      home: const LoginScreen(),
    );
  }
}
