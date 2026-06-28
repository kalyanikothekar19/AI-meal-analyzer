import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_analyzer/providers/history_provider.dart';
import '../data/services/claude_service.dart';
import '../data/models/meal_result.dart';

// ── Service provider (singleton) ──────────────────────────────────────────
final claudeServiceProvider = Provider<ClaudeService>((ref) {
  return ClaudeService();
});

// ── Selected image file ────────────────────────────────────────────────────
final selectedImageProvider = StateProvider<File?>((ref) => null);

// ── Main meal analysis state ───────────────────────────────────────────────
// AsyncNotifier handles loading / data / error cleanly
class MealAnalysisNotifier extends AsyncNotifier<MealResult?> {
  @override
  Future<MealResult?> build() async => null; // starts empty

  /// Pick image from camera or gallery, then auto-analyze
  Future<void> pickAndAnalyze(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85, // compress a bit for faster upload
    );

    if (picked == null) return; // user cancelled

    final imageFile = File(picked.path);

    // Store the file so the UI can show a preview
    ref.read(selectedImageProvider.notifier).state = imageFile;

    // Trigger analysis — AsyncNotifier handles loading state automatically
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(claudeServiceProvider);
      final result = await service.analyzeMeal(imageFile);

      // Auto-save to history after successful analysis
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.saveMeal(result);

      // Refresh history
      ref.invalidate(mealHistoryProvider);

      return result;
    });
  }

  void reset() {
    state = const AsyncData(null);
    ref.read(selectedImageProvider.notifier).state = null;
  }
}

final mealAnalysisProvider =
    AsyncNotifierProvider<MealAnalysisNotifier, MealResult?>(
  MealAnalysisNotifier.new,
);
