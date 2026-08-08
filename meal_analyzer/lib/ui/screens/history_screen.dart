import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/meal_result.dart';
import '../../providers/history_provider.dart';
import '../widgets/history_tile.dart';
import 'result_screen.dart';
import '../../data/firestore_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mealHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Could not load history', style: AppTheme.headingMedium),
              const SizedBox(height: 8),
              Text(err.toString(),
                  style: AppTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(mealHistoryProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (history) => history.isEmpty
            ? const _EmptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryBar(history: history),

                  // ── Report trigger card instead of always-visible report ──
                  _ReportTriggerCard(
                    onTap: () => _openReportSheet(context, ref, history),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                    child: Text(
                      '${history.length} meal${history.length == 1 ? '' : 's'} '
                      'analysed  ·  Swipe left to delete',
                      style: AppTheme.labelSmall,
                    ),
                  ),

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
                                builder: (_) => ResultScreen(meal: meal)),
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

  // ── Open the report as a bottom sheet popup ───────────────────────────────
  void _openReportSheet(
      BuildContext context, WidgetRef ref, List<MealResult> history) {
    // TODO: confirm `meal.timestamp` is the correct field name on MealResult
    final todayMeals = history.where((m) => _isToday(m.analyzedAt)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _NutritionReportCard(
                    history: todayMeals,
                    onSave: () =>
                        _saveReportToFirestore(context, ref, todayMeals),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ── Save today's aggregated report to Firestore ───────────────────────────
  Future<void> _saveReportToFirestore(
      BuildContext context, WidgetRef ref, List<MealResult> todayMeals) async {
    int totalCalories = 0;
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (final m in todayMeals) {
      totalCalories += m.calories;
      totalProtein += m.protein;
      totalCarbs += m.carbs;
      totalFat += m.fat;
    }

    try {
      final firestoreService = FirestoreService();
      await firestoreService.saveDailyReport(
        date: DateTime.now(),
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        mealCount: todayMeals.length,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved ✅')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save report: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteMeal(
      BuildContext context, WidgetRef ref, MealResult meal) async {
    if (meal.firestoreId == null) return;
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteMeal(meal.firestoreId!);
      ref.invalidate(mealHistoryProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History?'),
        content: const Text(
            'This will permanently delete all your saved meals from the cloud.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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
                        backgroundColor: Colors.redAccent),
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

// ── New: card that triggers the report popup ───────────────────────────────
class _ReportTriggerCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportTriggerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "View Today's Nutrition Report",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cumulative stats bar (unchanged — still all-time totals) ───────────────
class _SummaryBar extends StatelessWidget {
  final List<MealResult> history;
  const _SummaryBar({required this.history});

  @override
  Widget build(BuildContext context) {
    int totalCalories = 0;
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
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
              color: AppTheme.primaryLight),
          _VerticalDivider(),
          _Stat(
              label: 'Protein',
              value: '${totalProtein.toStringAsFixed(0)}g',
              color: AppTheme.proteinColor),
          _VerticalDivider(),
          _Stat(
              label: 'Carbs',
              value: '${totalCarbs.toStringAsFixed(0)}g',
              color: AppTheme.carbsColor),
          _VerticalDivider(),
          _Stat(
              label: 'Fat',
              value: '${totalFat.toStringAsFixed(0)}g',
              color: AppTheme.fatColor),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFFEEEEEE));
  }
}

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
                borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.no_meals_rounded,
                size: 48, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 20),
          Text('No meals yet', style: AppTheme.headingMedium),
          const SizedBox(height: 8),
          Text('Analyse your first meal to see it here',
              style: AppTheme.bodyMedium),
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

// ── Nutrition report (now popup content, filtered to today, + save button) ─
class _NutritionReportCard extends StatelessWidget {
  final List<MealResult> history; // already filtered to today by caller
  final VoidCallback onSave;

  const _NutritionReportCard({required this.history, required this.onSave});

  static const int targetCalories = 2000;
  static const double targetProtein = 50;
  static const double targetCarbs = 275;
  static const double targetFat = 78;

  @override
  Widget build(BuildContext context) {
    int totalCalories = 0;
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (final m in history) {
      totalCalories += m.calories;
      totalProtein += m.protein;
      totalCarbs += m.carbs;
      totalFat += m.fat;
    }

    final gaps = <_NutrientGap>[
      _NutrientGap('Calories', totalCalories.toDouble(),
          targetCalories.toDouble(), 'kcal', AppTheme.primaryLight),
      _NutrientGap(
          'Protein', totalProtein, targetProtein, 'g', AppTheme.proteinColor),
      _NutrientGap('Carbs', totalCarbs, targetCarbs, 'g', AppTheme.carbsColor),
      _NutrientGap('Fat', totalFat, targetFat, 'g', AppTheme.fatColor),
    ];

    final shortfalls = gaps.where((g) => g.remaining > 0).toList()
      ..sort(
          (a, b) => (b.remaining / b.target).compareTo(a.remaining / a.target));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insights_rounded,
                size: 20, color: Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text("Today's Nutrition Report", style: AppTheme.headingMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          history.isEmpty
              ? "No meals logged today yet."
              : shortfalls.isEmpty
                  ? "You've met all your daily targets. Great job!"
                  : "You still need more ${shortfalls.first.label.toLowerCase()} to hit today's goal.",
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        ...gaps.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _GapRow(gap: g),
            )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: history.isEmpty ? null : onSave,
            icon: const Icon(Icons.cloud_upload_rounded, size: 18),
            label: const Text('Save Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientGap {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final Color color;

  _NutrientGap(this.label, this.consumed, this.target, this.unit, this.color);

  double get remaining => (target - consumed).clamp(0, target);
  double get progress => (consumed / target).clamp(0.0, 1.0);
}

class _GapRow extends StatelessWidget {
  final _NutrientGap gap;
  const _GapRow({required this.gap});

  @override
  Widget build(BuildContext context) {
    final isComplete = gap.remaining <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(gap.label,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
            Text(
              isComplete
                  ? 'Goal met'
                  : 'Need ${gap.remaining.toStringAsFixed(0)}${gap.unit} more',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isComplete ? Colors.green : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: gap.progress,
            minHeight: 7,
            backgroundColor: gap.color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(gap.color),
          ),
        ),
      ],
    );
  }
}
