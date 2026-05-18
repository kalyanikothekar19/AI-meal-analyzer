import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/meal_result.dart';

class MealHistoryNotifier extends Notifier<List<MealResult>> {
  static const _boxName = 'meal_history';

  @override
  List<MealResult> build() {
    // Load from Hive on startup
    final box = Hive.box<MealResult>(_boxName);
    return box.values.toList().reversed.toList(); // newest first
  }

  Future<void> addMeal(MealResult meal) async {
    final box = Hive.box<MealResult>(_boxName);
    await box.add(meal);
    state = box.values.toList().reversed.toList();
  }

  Future<void> deleteMeal(int index) async {
    final box = Hive.box<MealResult>(_boxName);
    await box.deleteAt(index);
    state = box.values.toList().reversed.toList();
  }
}

final mealHistoryProvider =
    NotifierProvider<MealHistoryNotifier, List<MealResult>>(
  MealHistoryNotifier.new,
);