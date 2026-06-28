import 'package:flutter/material.dart';
import 'package:meal_analyzer/data/services/auth_service.dart';
import '../../../core/theme.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email address');
      hasError = true;
    }
    if (password.isEmpty || password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);
    String? _error;

    // TODO: Replace with Firebase Auth call:
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    //   // Navigate to home
    // } on FirebaseAuthException catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.message ?? 'Login failed')),
    //   );
    // } finally {
    //   setState(() => _isLoading = false);
    // }

    try {
      // if (_isLogin) {
        await _auth.signInWithEmail(email, password);
      // } else {
      //   await _auth.signUpWithEmail(email, password);
      // }
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    }

    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    if (mounted) setState(() => _isLoading = false);
  }

  // Future<void> _handleEmailAuth() async {
  //   setState(() => _error = null);
  //   try {
  //     if (_isLogin) {
  //       await _auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
  //     } else {
  //       await _auth.signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
  //     }
  //   } on Exception catch (e) {
  //     setState(() => _error = e.toString());
  //   }
  // }

  // Future<void> _handleGoogle() async {
  //   setState(() => _error = null);
  //   try {
  //     await _auth.signInWithGoogle();
  //   } on Exception catch (e) {
  //     setState(() => _error = e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Email Field ──────────────────────────────────────────────────
          _InputLabel(label: 'Email Address'),
          const SizedBox(height: 8),
          _RoundedTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) => setState(() => _emailError = null),
          ),

          const SizedBox(height: 18),

          // ── Password Field ────────────────────────────────────────────────
          _InputLabel(label: 'Password'),
          const SizedBox(height: 8),
          _RoundedTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            errorText: _passwordError,
            onChanged: (_) => setState(() => _passwordError = null),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  key: ValueKey(_obscurePassword),
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Forgot Password ───────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => forgotPassword()),
                );
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ── Login Button ──────────────────────────────────────────────────
          _GradientLoginButton(
            isLoading: _isLoading,
            onPressed: _validateAndLogin,
            flag:'login'
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError
                ? const Color(0xFFFFF3F3)
                : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE57373)
                  : const Color(0xFFE8ECF0),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppTheme.textMuted.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  prefixIcon,
                  color: hasError
                      ? const Color(0xFFE57373)
                      : AppTheme.primary,
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GradientLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String flag;
  const _GradientLoginButton({
    required this.isLoading,
    required this.onPressed,
    required this.flag
  });

  @override
  State<_GradientLoginButton> createState() => _GradientLoginButtonState();
}

class _GradientLoginButtonState extends State<_GradientLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        widget.onPressed();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
                Color(0xFFFF9800),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                       widget.flag =='login'? 'Login' :'Submit',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class forgotPassword extends StatefulWidget{
  @override
  State<forgotPassword> createState() => forgotPasswordState();
}

class forgotPasswordState extends State<forgotPassword>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String  _emailError='';
  final _auth= AuthService();


  Future<void> _forgotPass() async {
    // 1. Start loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Wait for the email to send
      // (Make sure your _auth.sendPasswordReset returns a Future!)
      await _auth.sendPasswordReset(_emailController.text.trim());

      // 3. Check if widget is still on screen before showing UI
      if (!mounted) return; 

      // 4. Show the success message (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // How long the message stays
        ),
      );

      // 5. Wait for 2 seconds so the user has time to read the message
      await Future.delayed(const Duration(seconds: 2));

      // 6. Redirect back to the Login Page
      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      // Show an error message if it fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send email. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 7. Stop the loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
 @override
  Widget build(BuildContext context) {
    // 1. Wrap everything in a Scaffold
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Keeps the background color consistent
        elevation: 0, // Removes the shadow under the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Manually go back to login without sending an email
            Navigator.pop(context); 
          },
        ),
      ),
      body: Center( 
        child: SingleChildScrollView(
          child: Container(
            // ── Your existing Container code stays exactly the same below here ──
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tells the column to only take up as much space as it needs
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InputLabel(label: 'Email Address'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError.isEmpty ? null : _emailError,
                  onChanged: (_) => setState(() => _emailError = ''),
                ),
                const SizedBox(height: 18),
                _GradientLoginButton(
                  isLoading: _isLoading,
                  onPressed: _forgotPass,
                  flag:'forgot'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
  
