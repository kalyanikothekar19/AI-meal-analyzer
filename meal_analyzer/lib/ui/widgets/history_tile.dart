import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/meal_result.dart';

/// A swipeable card tile that shows a summary of one saved [MealResult].
///
/// Swipe left to reveal the red delete background and trigger [onDelete].
/// Tap the tile to navigate to the full result (handled by the parent list).
class HistoryTile extends StatelessWidget {
  final MealResult meal;
  final VoidCallback? onDelete;

  const HistoryTile({
    super.key,
    required this.meal,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(meal.analyzedAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: _buildThumbnail(),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal name
                    Text(
                      meal.mealName,
                      style: AppTheme.headingMedium.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Timestamp
                    Text(
                      _formatDate(meal.analyzedAt),
                      style: AppTheme.labelSmall,
                    ),

                    const SizedBox(height: 10),

                    // Macro badges row
                    // Macro badges row — scrollable so it never overflows on narrow screens
                    SizedBox(
                      height:
                          26, // match your badge height so it doesn't add extra vertical space
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          _MacroBadge(
                            label: '${meal.calories} kcal',
                            color: AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          _MacroBadge(
                            label: '${meal.protein.toStringAsFixed(0)}g P',
                            color: AppTheme.proteinColor,
                          ),
                          const SizedBox(width: 6),
                          _MacroBadge(
                            label: '${meal.carbs.toStringAsFixed(0)}g C',
                            color: AppTheme.carbsColor,
                          ),
                          const SizedBox(width: 6),
                          _MacroBadge(
                            label: '${meal.fat.toStringAsFixed(0)}g F',
                            color: AppTheme.fatColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Chevron ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildThumbnail() {
    final file = File(meal.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
      );
    }
    // Fallback when the local file no longer exists
    return Container(
      width: 88,
      height: 88,
      color: const Color(0xFFEEEEEE),
      child: const Icon(
        Icons.fastfood_rounded,
        color: Color(0xFFBBBBBB),
        size: 32,
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}  ·  $h:$m';
  }
}

// ── Small coloured badge for a macro value ─────────────────────────────────────
class _MacroBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
