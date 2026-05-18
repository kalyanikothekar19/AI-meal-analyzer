import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/meal_provider.dart';
import '../widgets/nutrition_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state — rebuilds whenever analysis state or image changes
    final analysisState = ref.watch(mealAnalysisProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final notifier = ref.read(mealAnalysisProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tagline ──────────────────────────────────────────────────────
            Text(
              AppConstants.tagline,
              style: AppTheme.labelSmall.copyWith(
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(height: 16),

            // ── Image Preview ─────────────────────────────────────────────────
            GestureDetector(
              onTap: () => _showPickerSheet(context, notifier),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 260,
                decoration: selectedImage != null
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x20000000),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      )
                    : AppTheme.imagePlaceholderDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: selectedImage != null
                      ? Image.file(selectedImage, fit: BoxFit.cover)
                      : const _EmptyImagePlaceholder(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Action Buttons ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => notifier.pickAndAnalyze(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => notifier.pickAndAnalyze(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Result / Loading / Error ───────────────────────────────────────
            // AsyncNotifier gives us .when() — no manual if/else needed
            analysisState.when(
              data: (result) {
                if (result == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NutritionCard(meal: result),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () => notifier.reset(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Analyze Another Meal'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const _LoadingIndicator(),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet to choose camera or gallery ──────────────────────────────
  void _showPickerSheet(
      BuildContext context, MealAnalysisNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose Image Source', style: AppTheme.headingMedium),
              const SizedBox(height: 8),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt_rounded,
                      color: AppTheme.primary),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your device camera'),
                onTap: () {
                  Navigator.pop(context);
                  notifier.pickAndAnalyze(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library_rounded,
                      color: Color(0xFF1565C0)),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  notifier.pickAndAnalyze(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty image placeholder (shown before any photo is picked) ─────────────────
class _EmptyImagePlaceholder extends StatelessWidget {
  const _EmptyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 34,
            color: AppTheme.primaryLight,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to take or pick a photo',
          style: AppTheme.bodyMedium.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          'AI will analyse calories & macros',
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }
}

// ── Camera / Gallery button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

// ── Loading indicator (shown while Claude API call is in progress) ────────────
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: AppTheme.cardDecoration,
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Analysing your meal…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF444444),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Claude Vision is working on it 🤖',
            style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }
}

// ── Error card ─────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analysis Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}