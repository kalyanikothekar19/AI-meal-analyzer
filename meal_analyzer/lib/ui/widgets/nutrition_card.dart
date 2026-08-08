import 'package:flutter/material.dart';
import 'package:meal_analyzer/core/theme.dart';
import 'package:meal_analyzer/ui/widgets/recipe_carousel_sheet.dart';
import '../../data/models/meal_result.dart';
import 'macro_bar.dart';

class NutritionCard extends StatelessWidget {
  final MealResult meal;
  const NutritionCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name + calorie badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  meal.mealName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${meal.calories} kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Macro bars
          MacroBar(
              label: 'Protein',
              value: meal.protein,
              color: const Color(0xFF2196F3),
              unit: 'g'),
          const SizedBox(height: 10),
          MacroBar(
              label: 'Carbs',
              value: meal.carbs,
              color: const Color(0xFFFF9800),
              unit: 'g'),
          const SizedBox(height: 10),
          MacroBar(
              label: 'Fat',
              value: meal.fat,
              color: const Color(0xFFF44336),
              unit: 'g'),

          const SizedBox(height: 20),

          // Health tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    meal.healthTip,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => RecipeCarouselSheet(
                      foodName: meal.mealName), // adjust field name if needed
                );
              },
              icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
              label: const Text('View Recipes with this Food'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
