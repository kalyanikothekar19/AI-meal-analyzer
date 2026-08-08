import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_analyzer/data/services/auth_service.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/meal_provider.dart';
import '../widgets/nutrition_card.dart';

// ✨ Meal & Health Themed Background Painter
class _MealHealthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient (base)
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF0F7F4), // Soft mint green
          const Color(0xFFFFEDD5), // Warm cream
          const Color(0xFFF1F8E9), // Light green
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );

    // ---- Decorative Elements ----
    final paintSmall = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    final paintTiny = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    // Apple icon pattern (top left)
    _drawApple(canvas, Offset(30, 80), 45, paintSmall);
    _drawApple(canvas, Offset(size.width - 40, 120), 50, paintTiny);

    // Salad/bowl patterns (middle)
    _drawBowl(canvas, Offset(50, size.height * 0.35), 40, paintSmall);
    _drawBowl(
        canvas, Offset(size.width - 60, size.height * 0.5), 48, paintTiny);

    // Dumbbells (fitness element)
    _drawDumbbell(
        canvas, Offset(size.width * 0.85, size.height * 0.25), 35, paintTiny);
    _drawDumbbell(canvas, Offset(35, size.height * 0.7), 42, paintSmall);

    // Heart (health element)
    _drawHeart(
        canvas, Offset(size.width - 45, size.height * 0.8), 38, paintSmall);
    _drawHeart(
        canvas, Offset(size.width * 0.15, size.height * 0.15), 32, paintTiny);

    // Carrot (nutrition)
    _drawCarrot(
        canvas, Offset(size.width * 0.8, size.height * 0.65), 40, paintTiny);
    _drawCarrot(
        canvas, Offset(size.width * 0.2, size.height * 0.55), 45, paintSmall);

    // Subtle dots pattern for texture
    final dotPaint = Paint()..color = const Color(0xFF81C784).withOpacity(0.04);

    for (int i = 0; i < 15; i++) {
      final x = (i * 80).toDouble() % size.width;
      final y = ((i * 120) + 200).toDouble() % size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  // Draw apple
  void _drawApple(Canvas canvas, Offset center, double size, Paint paint) {
    // Circle body
    canvas.drawCircle(center, size * 0.5, paint);
    // Leaf
    canvas.drawCircle(
        center + Offset(size * 0.3, -size * 0.4), size * 0.25, paint);
  }

  // Draw bowl/salad
  void _drawBowl(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - size * 0.5, center.dy - size * 0.3);
    path.quadraticBezierTo(center.dx - size * 0.5, center.dy + size * 0.5,
        center.dx, center.dy + size * 0.6);
    path.quadraticBezierTo(center.dx + size * 0.5, center.dy + size * 0.5,
        center.dx + size * 0.5, center.dy - size * 0.3);
    canvas.drawPath(path, paint);
  }

  // Draw dumbbell
  void _drawDumbbell(Canvas canvas, Offset center, double size, Paint paint) {
    // Left weight
    canvas.drawCircle(center - Offset(size * 0.4, 0), size * 0.25, paint);
    // Bar
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size * 0.5,
        height: size * 0.15,
      ),
      paint,
    );
    // Right weight
    canvas.drawCircle(center + Offset(size * 0.4, 0), size * 0.25, paint);
  }

  // Draw heart
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.4);
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.1,
      center.dx - size * 0.5,
      center.dy - size * 0.4,
      center.dx - size * 0.2,
      center.dy - size * 0.4,
    );
    path.cubicTo(
      center.dx,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.5,
    );
    path.cubicTo(
      center.dx,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.6,
      center.dx + size * 0.2,
      center.dy - size * 0.4,
    );
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size * 0.4,
      center.dx + size * 0.5,
      center.dy - size * 0.1,
      center.dx,
      center.dy + size * 0.4,
    );
    canvas.drawPath(path, paint);
  }

  // Draw carrot
  void _drawCarrot(Canvas canvas, Offset center, double size, Paint paint) {
    // Carrot body (triangle)
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.5);
    path.lineTo(center.dx + size * 0.35, center.dy + size * 0.5);
    path.lineTo(center.dx - size * 0.35, center.dy + size * 0.5);
    path.close();
    canvas.drawPath(path, paint);

    // Leaf top
    canvas.drawCircle(center + Offset(0, -size * 0.5), size * 0.2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void _logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state — rebuilds whenever analysis state or image changes
    final analysisState = ref.watch(mealAnalysisProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final notifier = ref.read(mealAnalysisProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✨ Meal & Health Themed Background Wallpaper
          CustomPaint(
            painter: _MealHealthBackgroundPainter(),
            child: Container(),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── AppBar Section ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.tagline,
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.3,
                                color: const Color(0xFF558B2F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'History',
                              icon: const Icon(
                                Icons.history_rounded,
                                color: Color(0xFF2E7D32),
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/history'),
                            ),
                            IconButton(
                              tooltip: 'Log Out',
                              icon: const Icon(
                                Icons.logout,
                                color: Color(0xFF2E7D32),
                              ),
                              onPressed: () => _logout(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tagline ───────────────────────────────────────────────────
                  Text(
                    AppConstants.tagline,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.4,
                      color: const Color(0xFF558B2F),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Image Preview ─────────────────────────────────────────────
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

                  // ── Action Buttons ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          onTap: () =>
                              notifier.pickAndAnalyze(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          onTap: () =>
                              notifier.pickAndAnalyze(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Result / Loading / Error ───────────────────────────────────
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
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet to choose camera or gallery ──────────────────────────────
  void _showPickerSheet(BuildContext context, MealAnalysisNotifier notifier) {
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
                  child:
                      Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD6D6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                    fontSize: 15,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF7A7A7A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
