import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/meal_result.dart';
import '../widgets/nutrition_card.dart';

/// Full-screen detail view for a single [MealResult].
/// Reached by tapping a tile in HistoryScreen.
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => ResultScreen(meal: meal)),
/// );
/// ```
class ResultScreen extends StatelessWidget {
  final MealResult meal;

  const ResultScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible hero image app bar ───────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _buildHeroImage(),
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calorie rating banner
                  _CalorieBanner(calories: meal.calories),

                  const SizedBox(height: 16),

                  // Full nutrition card with macros & health tip
                  NutritionCard(meal: meal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    final file = File(meal.imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: double.infinity);
    }
    // Fallback placeholder
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Center(
        child: Icon(Icons.fastfood_rounded,
            size: 60, color: Color(0xFFBBBBBB)),
      ),
    );
  }
}

// ── Calorie rating banner ──────────────────────────────────────────────────────
class _CalorieBanner extends StatelessWidget {
  final int calories;

  const _CalorieBanner({required this.calories});

  // Rating label based on calorie range
  String get _label {
    if (calories < 300) return 'Light Meal 🌿';
    if (calories < 600) return 'Balanced Meal ✅';
    if (calories < 900) return 'Hearty Meal 🍽️';
    return 'High-Calorie Meal ⚠️';
  }

  // Colour matches the rating
  Color get _color {
    if (calories < 300) return const Color(0xFF00897B); // teal
    if (calories < 600) return AppTheme.primary;        // green
    if (calories < 900) return AppTheme.accent;         // orange
    return Colors.deepOrange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Rating + sub-label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Based on estimated calorie count',
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),

          // Large calorie number
          Text(
            '$calories',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}