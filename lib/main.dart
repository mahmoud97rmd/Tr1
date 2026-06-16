import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'features/dashboard/presentation/main_layout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GoldScalperApp(),
    ),
  );
}

class GoldScalperApp extends StatelessWidget {
  const GoldScalperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Scalper Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MainLayoutScreen(),
    );
  }
}
