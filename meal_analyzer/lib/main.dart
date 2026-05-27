import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/meal_result.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/history_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(MealResultAdapter());
  await Hive.openBox<MealResult>('meal_history');

  runApp(
    // ProviderScope wraps the entire app — required for Riverpod
    const ProviderScope(
      child: MealAnalyzerApp(),
    ),
  );
}

class MealAnalyzerApp extends StatelessWidget {
  const MealAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Analyzer',
      theme: AppTheme.light,
      home: const HomeScreen(),
      routes: {
        '/history': (_) => const HistoryScreen(),
      },
    );
  }
}
