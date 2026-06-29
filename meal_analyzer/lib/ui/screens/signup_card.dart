// import 'package:flutter/material.dart';
// import 'package:meal_analyzer/data/services/auth_service.dart';
// import '../../../core/theme.dart';

// class SignupCard extends StatefulWidget {
//   const SignupCard({super.key});

//   @override
//   State<SignupCard> createState() => _SignupCardState();
// }

// class _SignupCardState extends State<SignupCard> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;
//   bool _agreedToTerms = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   String? _validateName(String? v) {
//     if (v == null || v.trim().isEmpty) return 'Please enter your full name';
//     if (v.trim().length < 2) return 'Name must be at least 2 characters';
//     return null;
//   }

//   String? _validateEmail(String? v) {
//     if (v == null || v.trim().isEmpty) return 'Please enter your email';
//     if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
//       return 'Please enter a valid email address';
//     }
//     return null;
//   }

//   String? _validatePassword(String? v) {
//     if (v == null || v.isEmpty) return 'Please enter a password';
//     if (v.length < 8) return 'Password must be at least 8 characters';
//     if (!v.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
//     if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
//     return null;
//   }

//   String? _validateConfirmPassword(String? v) {
//     if (v == null || v.isEmpty) return 'Please confirm your password';
//     if (v != _passwordController.text) return 'Passwords do not match';
//     return null;
//   }

//   void _handleSignup() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_agreedToTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please agree to Terms & Privacy Policy'),
//           backgroundColor: Colors.red.shade400,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     // TODO: Firebase Auth signup:
//     // try {
//     //   final credential = await FirebaseAuth.instance
//     //       .createUserWithEmailAndPassword(
//     //         email: _emailController.text.trim(),
//     //         password: _passwordController.text,
//     //       );
//     //   await credential.user?.updateDisplayName(_nameController.text.trim());
//     //   // Navigate to home or profile setup
//     // } on FirebaseAuthException catch (e) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text(e.message ?? 'Signup failed')),
//     //   );
//     // } finally {
//     //   if (mounted) setState(() => _isLoading = false);
//     // }
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final auth = AuthService();
//     try{
//       await auth.signUpWithEmail(email,password);
//     } on Exception catch(e){
//       print(e);
//     }
//     await Future.delayed(const Duration(seconds: 2));
//     if (mounted) setState(() => _isLoading = false);
//   }

//   // Password strength helper
//   int _getPasswordStrength(String password) {
//     int strength = 0;
//     if (password.length >= 8) strength++;
//     if (password.contains(RegExp(r'[A-Z]'))) strength++;
//     if (password.contains(RegExp(r'[0-9]'))) strength++;
//     if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
//     return strength;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final passwordStrength = _getPasswordStrength(_passwordController.text);

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primary.withOpacity(0.08),
//             blurRadius: 40,
//             offset: const Offset(0, 12),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(26),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── Full Name ────────────────────────────────────────────────
//             _InputLabel(label: 'Full Name'),
//             const SizedBox(height: 8),
//             _SignupTextField(
//               controller: _nameController,
//               hintText: 'Enter your full name',
//               prefixIcon: Icons.person_outline_rounded,
//               validator: _validateName,
//               keyboardType: TextInputType.name,
//               textCapitalization: TextCapitalization.words,
//             ),

//             const SizedBox(height: 16),

//             // ── Email ────────────────────────────────────────────────────
//             _InputLabel(label: 'Email Address'),
//             const SizedBox(height: 8),
//             _SignupTextField(
//               controller: _emailController,
//               hintText: 'Enter your email',
//               prefixIcon: Icons.email_outlined,
//               validator: _validateEmail,
//               keyboardType: TextInputType.emailAddress,
//             ),

//             const SizedBox(height: 16),

//             // ── Password ─────────────────────────────────────────────────
//             _InputLabel(label: 'Password'),
//             const SizedBox(height: 8),
//             _SignupTextField(
//               controller: _passwordController,
//               hintText: 'Create a strong password',
//               prefixIcon: Icons.lock_outline_rounded,
//               obscureText: _obscurePassword,
//               validator: _validatePassword,
//               onChanged: (_) => setState(() {}),
//               suffixIcon: GestureDetector(
//                 onTap: () =>
//                     setState(() => _obscurePassword = !_obscurePassword),
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     key: ValueKey(_obscurePassword),
//                     color: AppTheme.textMuted,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),

//             // Password strength bar
//             if (_passwordController.text.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               _PasswordStrengthBar(strength: passwordStrength),
//             ],

//             const SizedBox(height: 16),

//             // ── Confirm Password ─────────────────────────────────────────
//             _InputLabel(label: 'Confirm Password'),
//             const SizedBox(height: 8),
//             _SignupTextField(
//               controller: _confirmPasswordController,
//               hintText: 'Re-enter your password',
//               prefixIcon: Icons.lock_outline_rounded,
//               obscureText: _obscureConfirm,
//               validator: _validateConfirmPassword,
//               onChanged: (_) => setState(() {}),
//               suffixIcon: GestureDetector(
//                 onTap: () =>
//                     setState(() => _obscureConfirm = !_obscureConfirm),
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     _obscureConfirm
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     key: ValueKey(_obscureConfirm),
//                     color: AppTheme.textMuted,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 18),

//             // ── Terms & Conditions ───────────────────────────────────────
//             _TermsCheckbox(
//               value: _agreedToTerms,
//               onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
//             ),

//             const SizedBox(height: 22),

//             // ── Signup Button ─────────────────────────────────────────────
//             _GradientSignupButton(
//               isLoading: _isLoading,
//               onPressed: _handleSignup,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Reusable Input Label ───────────────────────────────────────────────────────
// class _InputLabel extends StatelessWidget {
//   final String label;
//   const _InputLabel({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontFamily: 'Nunito',
//         fontSize: 13.5,
//         fontWeight: FontWeight.w700,
//         color: AppTheme.textDark,
//         letterSpacing: 0.2,
//       ),
//     );
//   }
// }

// // ── Reusable Text Field ────────────────────────────────────────────────────────
// class _SignupTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final IconData prefixIcon;
//   final bool obscureText;
//   final TextInputType? keyboardType;
//   final TextCapitalization textCapitalization;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onChanged;

//   const _SignupTextField({
//     required this.controller,
//     required this.hintText,
//     required this.prefixIcon,
//     this.obscureText = false,
//     this.keyboardType,
//     this.textCapitalization = TextCapitalization.none,
//     this.suffixIcon,
//     this.validator,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       textCapitalization: textCapitalization,
//       onChanged: onChanged,
//       validator: validator,
//       style: const TextStyle(
//         fontFamily: 'Nunito',
//         fontSize: 15,
//         fontWeight: FontWeight.w600,
//         color: AppTheme.textDark,
//       ),
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(
//           fontFamily: 'Nunito',
//           fontSize: 14,
//           color: AppTheme.textMuted.withOpacity(0.7),
//           fontWeight: FontWeight.w500,
//         ),
//         filled: true,
//         fillColor: const Color(0xFFF6F8FA),
//         prefixIcon: Icon(prefixIcon, color: AppTheme.primary, size: 20),
//         suffixIcon: suffixIcon != null
//             ? Padding(padding: const EdgeInsets.only(right: 4), child: suffixIcon)
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF0), width: 1.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE8ECF0), width: 1.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE57373), width: 2),
//         ),
//         errorStyle: const TextStyle(
//           fontFamily: 'Nunito',
//           fontSize: 12,
//           color: Color(0xFFE57373),
//           fontWeight: FontWeight.w600,
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//       ),
//     );
//   }
// }

// // ── Password Strength Bar ──────────────────────────────────────────────────────
// class _PasswordStrengthBar extends StatelessWidget {
//   final int strength; // 0-4

//   const _PasswordStrengthBar({required this.strength});

//   Color get _color {
//     switch (strength) {
//       case 1: return const Color(0xFFEF5350);
//       case 2: return const Color(0xFFFF9800);
//       case 3: return const Color(0xFFFFEB3B);
//       case 4: return const Color(0xFF4CAF50);
//       default: return Colors.grey.shade200;
//     }
//   }

//   String get _label {
//     switch (strength) {
//       case 1: return 'Weak';
//       case 2: return 'Fair';
//       case 3: return 'Good';
//       case 4: return 'Strong ✓';
//       default: return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: List.generate(4, (i) {
//             return Expanded(
//               child: Container(
//                 margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
//                 height: 4,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(2),
//                   color: i < strength ? _color : Colors.grey.shade200,
//                 ),
//               ),
//             );
//           }),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           _label,
//           style: TextStyle(
//             fontFamily: 'Nunito',
//             fontSize: 11.5,
//             fontWeight: FontWeight.w700,
//             color: _color,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Terms Checkbox ─────────────────────────────────────────────────────────────
// class _TermsCheckbox extends StatelessWidget {
//   final bool value;
//   final ValueChanged<bool?> onChanged;

//   const _TermsCheckbox({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onChanged(!value),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 22,
//             height: 22,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(6),
//               color: value ? AppTheme.primary : Colors.transparent,
//               border: Border.all(
//                 color: value ? AppTheme.primary : const Color(0xFFDDE2E8),
//                 width: 1.8,
//               ),
//             ),
//             child: value
//                 ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
//                 : null,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(
//                   fontFamily: 'Nunito',
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.textMuted,
//                   height: 1.5,
//                 ),
//                 children: [
//                   const TextSpan(text: 'I agree to the '),
//                   TextSpan(
//                     text: 'Terms of Service',
//                     style: const TextStyle(
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w700,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                   const TextSpan(text: ' and '),
//                   TextSpan(
//                     text: 'Privacy Policy',
//                     style: const TextStyle(
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w700,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Gradient Signup Button ─────────────────────────────────────────────────────
// class _GradientSignupButton extends StatefulWidget {
//   final bool isLoading;
//   final VoidCallback onPressed;

//   const _GradientSignupButton({
//     required this.isLoading,
//     required this.onPressed,
//   });

//   @override
//   State<_GradientSignupButton> createState() => _GradientSignupButtonState();
// }

// class _GradientSignupButtonState extends State<_GradientSignupButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pressController;

//   @override
//   void initState() {
//     super.initState();
//     _pressController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//       lowerBound: 0.95,
//       upperBound: 1.0,
//       value: 1.0,
//     );
//   }

//   @override
//   void dispose() {
//     _pressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _pressController.reverse(),
//       onTapUp: (_) {
//         _pressController.forward();
//         widget.onPressed();
//       },
//       onTapCancel: () => _pressController.forward(),
//       child: ScaleTransition(
//         scale: _pressController,
//         child: Container(
//           height: 56,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 Color(0xFF4CAF50),
//                 Color(0xFF66BB6A),
//                 Color(0xFFFF9800),
//               ],
//               stops: [0.0, 0.55, 1.0],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF4CAF50).withOpacity(0.35),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Center(
//             child: widget.isLoading
//                 ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Create Account',
//                         style: TextStyle(
//                           fontFamily: 'Nunito',
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.25),
//                         ),
//                         child: const Icon(
//                           Icons.arrow_forward_rounded,
//                           color: Colors.white,
//                           size: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meal_analyzer/data/services/auth_service.dart';
import 'package:meal_analyzer/ui/screens/home_screen.dart';
// If you have a Firestore service, import it here
// import 'package:meal_analyzer/data/services/firestore_service.dart'; 
import '../../../core/theme.dart';

class SignupCard extends StatefulWidget {
  final Function(int)? onStepChanged;

  const SignupCard({super.key, this.onStepChanged});

  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  // ── Step State ─────────────────────────────────────────────────────────────
  int _currentStep = 0; // 0: Account, 1: Profile, 2: Goals

  // ── Account Controllers ────────────────────────────────────────────────────
  final _accountFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  // ── Profile Controllers ────────────────────────────────────────────────────
  final _profileFormKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'Male';

  // ── Goals State ────────────────────────────────────────────────────────────
  String _selectedGoal = 'Lose Weight';
  String _selectedActivity = 'Lightly Active';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ── Public Method for Header Routing ───────────────────────────────────────
  void setStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  // ── Validation Methods ─────────────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your full name';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateNumber(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Invalid';
    return null;
  }

  int _getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  // ── Action Handlers ────────────────────────────────────────────────────────
  void _handleMainAction() {
    if (_currentStep == 0) {
      _handleAccountContinue();
    } else if (_currentStep == 1) {
      _handleProfileContinue();
    } else if (_currentStep == 2) {
      _handleFinalSubmit();
    }
  }

  void _handleAccountContinue() {
    if (!_accountFormKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to Terms & Privacy Policy'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    // Just move to the next step, no network calls yet
    setState(() => _currentStep = 1);
    widget.onStepChanged?.call(2); 
  }

  void _handleProfileContinue() {
    if (!_profileFormKey.currentState!.validate()) return;
    
    // Just move to the final step
    setState(() => _currentStep = 2); 
    widget.onStepChanged?.call(3); 
  }

  // ── The Big Finale: Create Auth & Save Firestore Data ──────────────────────
  void _handleFinalSubmit() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    
    final auth = AuthService();
    
    try {
      // 1. Create the user in Firebase Auth
      // await auth.signUpWithEmail(email, password);
      // final currentUser = FirebaseAuth.instance.currentUser;
      // 2. Prepare the remaining user data for Firestore
      final userData = {
        'fullname': name,
        'email': email,
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _selectedGender,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'primarygoal': _selectedGoal,
        'activitylevel': _selectedActivity,
        'createdAt': DateTime.now().toIso8601String(),
      };

      print('✅ Auth Created Successfully!');
      print('💾 Saving to Firestore: $userData');
      await auth.createUserProfile('aap3J72WmDQGRpDMo2MeDZ7avom2',userData);
      // 3. Navigate away to the main dashboard
            if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

    } on Exception catch (e) {
      print('❌ Error during signup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create account. Please try again.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getButtonText() {
    if (_currentStep == 0) return 'Continue';
    if (_currentStep == 1) return 'Continue';
    return 'Create Account'; // Only show this on the final step
  }

  // ── Build Methods ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── The Swapping Form Fields ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentStepInputs(),
            ),
          ),

          const SizedBox(height: 18),

          // ── The Terms & Conditions (Only visible on Step 0) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _currentStep == 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: _TermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── The Main Action Button ──
          _GradientSignupButton(
            text: _getButtonText(),
            isLoading: _isLoading,
            onPressed: _handleMainAction,
          ),
        ],
      ),
    );
  }

  // ── Step View Router ───────────────────────────────────────────────────────
  Widget _buildCurrentStepInputs() {
    switch (_currentStep) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildProfileStep();
      case 2:
        return _buildGoalsStep();
      default:
        return _buildAccountStep();
    }
  }

  // ── Step 0: Account Inputs ─────────────────────────────────────────────────
  Widget _buildAccountStep() {
    final passwordStrength = _getPasswordStrength(_passwordController.text);

    return Form(
      key: _accountFormKey,
      child: Column(
        key: const ValueKey('step_0'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputLabel(label: 'Full Name'),
          const SizedBox(height: 8),
          _SignupTextField(
            controller: _nameController,
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            validator: _validateName,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _InputLabel(label: 'Email Address'),
          const SizedBox(height: 8),
          _SignupTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _InputLabel(label: 'Password'),
          const SizedBox(height: 8),
          _SignupTextField(
            controller: _passwordController,
            hintText: 'Create a strong password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            onChanged: (_) => setState(() {}),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  key: ValueKey(_obscurePassword),
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PasswordStrengthBar(strength: passwordStrength),
          ],
          const SizedBox(height: 16),
          _InputLabel(label: 'Confirm Password'),
          const SizedBox(height: 8),
          _SignupTextField(
            controller: _confirmPasswordController,
            hintText: 'Re-enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirm,
            validator: _validateConfirmPassword,
            onChanged: (_) => setState(() {}),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  key: ValueKey(_obscureConfirm),
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Profile Inputs ─────────────────────────────────────────────────
  Widget _buildProfileStep() {
    return Form(
      key: _profileFormKey,
      child: Column(
        key: const ValueKey('step_1'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputLabel(label: 'Age'),
                    const SizedBox(height: 8),
                    _SignupTextField(
                      controller: _ageController,
                      hintText: 'Years',
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v, 'Age'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputLabel(label: 'Gender'),
                    const SizedBox(height: 8),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8ECF0), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                          items: ['Male', 'Female', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() => _selectedGender = newValue!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputLabel(label: 'Height (cm)'),
                    const SizedBox(height: 8),
                    _SignupTextField(
                      controller: _heightController,
                      hintText: 'e.g. 175',
                      prefixIcon: Icons.height,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v, 'Height'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InputLabel(label: 'Weight (kg)'),
                    const SizedBox(height: 8),
                    _SignupTextField(
                      controller: _weightController,
                      hintText: 'e.g. 70',
                      prefixIcon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateNumber(v, 'Weight'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Goals Inputs ───────────────────────────────────────────────────
  Widget _buildGoalsStep() {
    return Column(
      key: const ValueKey('step_2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InputLabel(label: 'Primary Goal'),
        const SizedBox(height: 12),
        _buildChoiceRow(
          ['Lose Weight', 'Maintain', 'Gain Muscle'],
          _selectedGoal,
          (val) => setState(() => _selectedGoal = val),
        ),
        const SizedBox(height: 24),
        _InputLabel(label: 'Activity Level'),
        const SizedBox(height: 12),
        _buildChoiceRow(
          ['Sedentary', 'Lightly Active', 'Very Active'],
          _selectedActivity,
          (val) => setState(() => _selectedActivity = val),
        ),
      ],
    );
  }

  Widget _buildChoiceRow(List<String> options, String selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.1) : const Color(0xFFF6F8FA),
              border: Border.all(
                color: isSelected ? AppTheme.primary : const Color(0xFFE8ECF0),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Reusable Input Label ───────────────────────────────────────────────────────
class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Reusable Text Field ────────────────────────────────────────────────────────
class _SignupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _SignupTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
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
        filled: true,
        fillColor: const Color(0xFFF6F8FA),
        prefixIcon: Icon(prefixIcon, color: AppTheme.primary, size: 20),
        suffixIcon: suffixIcon != null
            ? Padding(padding: const EdgeInsets.only(right: 4), child: suffixIcon)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8ECF0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8ECF0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 2),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          color: Color(0xFFE57373),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    );
  }
}

// ── Password Strength Bar ──────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0-4

  const _PasswordStrengthBar({required this.strength});

  Color get _color {
    switch (strength) {
      case 1: return const Color(0xFFEF5350);
      case 2: return const Color(0xFFFF9800);
      case 3: return const Color(0xFFFFEB3B);
      case 4: return const Color(0xFF4CAF50);
      default: return Colors.grey.shade200;
    }
  }

  String get _label {
    switch (strength) {
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong ✓';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < strength ? _color : Colors.grey.shade200,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _color,
          ),
        ),
      ],
    );
  }
}

// ── Terms Checkbox ─────────────────────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: value ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: value ? AppTheme.primary : const Color(0xFFDDE2E8),
                width: 1.8,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient Signup Button ─────────────────────────────────────────────────────
class _GradientSignupButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientSignupButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_GradientSignupButton> createState() => _GradientSignupButtonState();
}

class _GradientSignupButtonState extends State<_GradientSignupButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

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
        scale: _pressController,
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
                        widget.text,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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