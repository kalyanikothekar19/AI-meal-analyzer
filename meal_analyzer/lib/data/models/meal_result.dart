import 'package:hive_flutter/hive_flutter.dart';

part 'meal_result.g.dart';

@HiveType(typeId: 0)
class MealResult extends HiveObject {
  @HiveField(0)
  final String mealName;

  @HiveField(1)
  final int calories;

  @HiveField(2)
  final double protein;  // grams

  @HiveField(3)
  final double carbs;    // grams

  @HiveField(4)
  final double fat;      // grams

  @HiveField(5)
  final String healthTip;

  @HiveField(6)
  final String imagePath; // local file path

  @HiveField(7)
  final DateTime analyzedAt;

  MealResult({
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.healthTip,
    required this.imagePath,
    required this.analyzedAt,
  });

  // Parse from Claude's JSON response
  factory MealResult.fromJson(Map<String, dynamic> json, String imagePath) {
    return MealResult(
      mealName: json['meal_name'] ?? 'Unknown Meal',
      calories: json['calories'] ?? 0,
      protein: (json['protein_g'] ?? 0).toDouble(),
      carbs: (json['carbs_g'] ?? 0).toDouble(),
      fat: (json['fat_g'] ?? 0).toDouble(),
      healthTip: json['health_tip'] ?? '',
      imagePath: imagePath,
      analyzedAt: DateTime.now(),
    );
  }
}