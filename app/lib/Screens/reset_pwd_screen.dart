// forgot_pwd_screen.dart
// A page that allows a user to reset their password if they forgot it.

import 'package:FoodHood/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    final authService = AuthService(FirebaseAuth.instance);
    try {
      await authService.sendPasswordResetEmail(email);
      print('Password reset email sent successfully.');
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            largeTitle: const Text(
              'Reset Password',
              style: TextStyle(
                letterSpacing: -1.36,
              ),
            ),
            leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.arrow_left_circle_fill,
                  color: Color.fromRGBO(51, 117, 134, 1.0),
                  size: 30.0,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                }),
            border: const Border(bottom: BorderSide.none),
            stretch: true,
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 16.0),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Don't worry! It happens. Please enter the email address associated with your account.", // Add your content here
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 16.0),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0),
              child: CupertinoTextField(
                padding: EdgeInsets.all(16.0),
                placeholder: "Email Address",
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.secondarySystemGroupedBackground,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: CupertinoColors.secondarySystemGroupedBackground,
                ),
                controller: _emailController,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 64.0),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                color: Color.fromRGBO(51, 117, 134, 1.0),
                borderRadius: BorderRadius.circular(10),
                minSize: 44,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: _resetPassword,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.8,
                    color: CupertinoColors.secondarySystemGroupedBackground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
