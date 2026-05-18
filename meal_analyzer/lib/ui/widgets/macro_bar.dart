import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Displays a labelled, coloured progress bar for a single macro nutrient.
///
/// Usage:
/// ```dart
/// MacroBar(label: 'Protein', value: meal.protein, color: AppTheme.proteinColor)
/// MacroBar(label: 'Carbs',   value: meal.carbs,   color: AppTheme.carbsColor)
/// MacroBar(label: 'Fat',     value: meal.fat,     color: AppTheme.fatColor, maxValue: 80)
/// ```
class MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String unit;

  /// The value that represents 100 % width of the bar.
  /// Adjust per macro for a visually meaningful bar.
  final double maxValue;

  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.unit = 'g',
    this.maxValue = 100,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row ───────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Coloured dot + label
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(label, style: AppTheme.bodyMedium),
              ],
            ),
            // Value
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Progress bar ─────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}