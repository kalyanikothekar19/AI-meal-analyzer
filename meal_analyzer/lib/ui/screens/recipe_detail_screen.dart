import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/recipe.dart';

// Full recipe view — opened when a card in the carousel is tapped.
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final String foodName;

  const RecipeDetailScreen(
      {super.key, required this.recipe, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(recipe.title, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(recipe.description, style: AppTheme.bodyMedium),
          const SizedBox(height: 16),

          // Quick stats row
          Row(
            children: [
              _StatChip(icon: Icons.bolt_rounded, label: recipe.difficulty),
              const SizedBox(width: 10),
              _StatChip(
                  icon: Icons.schedule_rounded,
                  label: '${recipe.prepTimeMinutes} min'),
              const SizedBox(width: 10),
              _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: '${recipe.calories} kcal'),
            ],
          ),
          const SizedBox(height: 24),

          Text('Ingredients', style: AppTheme.headingMedium),
          const SizedBox(height: 10),
          ...recipe.ingredients.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: AppTheme.bodyMedium)),
                  ],
                ),
              )),
          if (recipe.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                recipe.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: const Color(0xFFF0F7F0),
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xFFF0F7F0),
                  child: const Icon(Icons.restaurant_rounded,
                      size: 48, color: AppTheme.primaryLight),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),
          Text('Steps', style: AppTheme.headingMedium),
          const SizedBox(height: 10),
          ...recipe.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primary.withOpacity(0.12),
                    child: Text('${index + 1}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(step, style: AppTheme.bodyMedium)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
