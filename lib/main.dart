import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';
import 'utils/theme_controller.dart';

void main() {
  runApp(const StockPortfolioApp());
}

class StockPortfolioApp extends StatelessWidget {
  const StockPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Stock Portfolio & Market Analyzer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: LoginScreen(
            onThemeChanged: (isDark) {
              themeModeNotifier.value = isDark
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        );
      },
    );
  }
}