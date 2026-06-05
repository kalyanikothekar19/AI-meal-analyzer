import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_analyzer/ui/screens/signup_screen.dart';
import 'data/models/meal_result.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/history_screen.dart';
import 'core/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ui/screens/auth_gate.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(MealResultAdapter());
  await Hive.openBox<MealResult>('meal_history');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      debugShowCheckedModeBanner: false, // Add this line
      title: 'Meal Analyzer',
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/history': (_) => const HistoryScreen(),
        '/signup': (_) => const SignupScreen(),
      },
    );
  }
}