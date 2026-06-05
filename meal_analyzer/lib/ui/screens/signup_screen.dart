import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/signup_card.dart';
import '../widgets/social_login_section.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardFadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _cardFadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F7F2),
              Color(0xFFF5F7FA),
              Color(0xFFFFFDF9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // ── Top Bar with back button ──────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _TopBar(),
                    ),

                    const SizedBox(height: 16),

                    // ── Header Illustration ───────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _SignupHeader(),
                    ),

                    const SizedBox(height: 22),

                    // ── Signup Card ───────────────────────────────────────────
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: const SignupCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Social Signup ─────────────────────────────────────────
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: const SocialLoginSection(),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Login Footer ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _cardFadeAnimation,
                      child: _LoginFooter(),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar with back arrow ────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Compact header — logo + welcome text ──────────────────────────────────────
class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Small floating logo with decorative ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Decorative outer ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.15),
                  width: 2,
                ),
              ),
            ),
            // Mid ring
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.06),
              ),
            ),
            // Logo badge
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.22),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                    ),
                  ),
                  // Replace with: Image.asset('assets/images/app_logo.png')
                  child: const Center(
                    child: Text('🍽️', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Welcome text
        const Text(
          'Create Account',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Start your nutrition journey today',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),

        const SizedBox(height: 14),

        // Step indicator pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepPill(label: 'Account', isActive: true, step: '1'),
            const SizedBox(width: 8),
            _StepConnector(),
            const SizedBox(width: 8),
            _StepPill(label: 'Profile', isActive: false, step: '2'),
            const SizedBox(width: 8),
            _StepConnector(),
            const SizedBox(width: 8),
            _StepPill(label: 'Goals', isActive: false, step: '3'),
          ],
        ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final String step;

  const _StepPill({
    required this.label,
    required this.isActive,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withOpacity(0.12)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withOpacity(0.4)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.primary : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.primary : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 1.5,
      color: Colors.grey.shade200,
    );
  }
}

// ── Already have account footer ────────────────────────────────────────────────
class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
