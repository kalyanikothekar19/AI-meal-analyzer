import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/theme.dart';

class SignupFooter extends StatelessWidget {
  const SignupFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14.5,
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
        children: [
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'Sign Up',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Navigate to sign up screen
                Navigator.pushNamed(context, '/signup');
              },
          ),
        ],
      ),
    );
  }
}
