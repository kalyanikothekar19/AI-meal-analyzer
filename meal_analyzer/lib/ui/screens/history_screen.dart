import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/meal_result.dart';
import '../../providers/history_provider.dart'; // update this to export mealHistoryProvider as FutureProvider
import '../widgets/history_tile.dart';
import 'result_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mealHistoryProvider is now a FutureProvider<List<MealResult>>
    final historyAsync = ref.watch(mealHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // Only show Clear All when data is loaded and non-empty
          historyAsync.maybeWhen(
            data: (history) => history.isNotEmpty
                ? TextButton.icon(
                    onPressed: () => _confirmClearAll(context, ref),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        // ── Loading state ──────────────────────────────────────────────────
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // ── Error state ────────────────────────────────────────────────────
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Could not load history',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(mealHistoryProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),

        // ── Data loaded ────────────────────────────────────────────────────
        data: (history) => history.isEmpty
            ? const _EmptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cumulative stats ───────────────────────────────────
                  _SummaryBar(history: history),

                  // ── Hint ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                    child: Text(
                      '${history.length} meal${history.length == 1 ? '' : 's'} '
                      'analysed  ·  Swipe left to delete',
                      style: AppTheme.labelSmall,
                    ),
                  ),

                  // ── Meal list ──────────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final meal = history[index];

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(meal: meal),
                            ),
                          ),
                          child: HistoryTile(
                            meal: meal,
                            onDelete: () => _deleteMeal(context, ref, meal),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Delete a single meal using its Firestore document ID ─────────────────
  Future<void> _deleteMeal(
      BuildContext context, WidgetRef ref, MealResult meal) async {
    // firestoreId is stored on the MealResult model (added in Step 6 of migration)
    if (meal.firestoreId == null) return;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteMeal(meal.firestoreId!);

      // Refresh the history list after deletion
      ref.invalidate(mealHistoryProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Confirm dialog before wiping all history ──────────────────────────────
  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete all your saved meals from the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final firestoreService = ref.read(firestoreServiceProvider);
                await firestoreService.clearAllMeals();
                ref.invalidate(mealHistoryProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ── Cumulative stats bar ───────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final List<MealResult> history;

  const _SummaryBar({required this.history});

  @override
  Widget build(BuildContext context) {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final m in history) {
      totalCalories += m.calories;
      totalProtein += m.protein;
      totalCarbs += m.carbs;
      totalFat += m.fat;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          _Stat(
            label: 'Total kcal',
            value: totalCalories.toString(),
            color: AppTheme.primaryLight,
          ),
          _VerticalDivider(),
          _Stat(
            label: 'Protein',
            value: '${totalProtein.toStringAsFixed(0)}g',
            color: AppTheme.proteinColor,
          ),
          _VerticalDivider(),
          _Stat(
            label: 'Carbs',
            value: '${totalCarbs.toStringAsFixed(0)}g',
            color: AppTheme.carbsColor,
          ),
          _VerticalDivider(),
          _Stat(
            label: 'Fat',
            value: '${totalFat.toStringAsFixed(0)}g',
            color: AppTheme.fatColor,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFEEEEEE),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F0),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.no_meals_rounded,
              size: 48,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Text('No meals yet', style: AppTheme.headingMedium),
          const SizedBox(height: 8),
          Text(
            'Analyse your first meal to see it here',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Analyse a Meal'),
          ),
        ],
      ),
    );
  }
}
