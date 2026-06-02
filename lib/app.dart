import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class MonsterEarphoneApp extends StatelessWidget {
  const MonsterEarphoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: '魔音控制台',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkCyberTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
