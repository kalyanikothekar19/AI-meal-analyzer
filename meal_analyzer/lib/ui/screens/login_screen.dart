// import 'package:flutter/material.dart';
// import '../../data/services/auth_service.dart';
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = AuthService();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   bool _isLogin = true; // toggle between Login / Sign Up
//   String? _error;

//   Future<void> _handleEmailAuth() async {
//     setState(() => _error = null);
//     try {
//       if (_isLogin) {
//         await _auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
//       } else {
//         await _auth.signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
//       }
//     } on Exception catch (e) {
//       setState(() => _error = e.toString());
//     }
//   }

//   Future<void> _handleGoogle() async {
//     setState(() => _error = null);
//     try {
//       await _auth.signInWithGoogle();
//     } on Exception catch (e) {
//       setState(() => _error = e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _isLogin ? 'Welcome Back' : 'Create Account',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             const SizedBox(height: 32),

//             // Email field
//             TextField(
//               controller: _emailCtrl,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 12),

//             // Password field
//             TextField(
//               controller: _passCtrl,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 8),

//             // Error message
//             if (_error != null)
//               Text(_error!, style: const TextStyle(color: Colors.red)),

//             const SizedBox(height: 16),

//             // Email/Password button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _handleEmailAuth,
//                 child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Google button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: _handleGoogle,
//                 icon: const Icon(Icons.g_mobiledata, size: 24),
//                 label: const Text('Continue with Google'),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Toggle Login / Signup
//             TextButton(
//               onPressed: () => setState(() => _isLogin = !_isLogin),
//               child: Text(
//                 _isLogin
//                     ? "Don't have an account? Sign Up"
//                     : 'Already have an account? Sign In',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/animated_illustration.dart';
import '../widgets/login_card.dart';
import '../widgets/social_login_section.dart';
import '../widgets/signup_footer.dart';
import '../../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
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

    // Staggered animation start
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
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
                    const SizedBox(height: 20),

                    // ── Animated Illustration ────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const AnimatedIllustration(),
                    ),

                    const SizedBox(height: 20),

                    // ── Welcome Text ─────────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _WelcomeText(),
                    ),

                    const SizedBox(height: 24),

                    // ── Login Card (slide up) ─────────────────────────────────
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: const LoginCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Social Login ──────────────────────────────────────────
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: const SocialLoginSection(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sign Up Footer ────────────────────────────────────────
                    FadeTransition(
                      opacity: _cardFadeAnimation,
                      child: const SignupFooter(),
                    ),

                    const SizedBox(height: 24),
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

class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login to continue analyzing your meals',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
