// forgot_pwd_screen.dart
// A page that allows a user to reset their password if they forgot it.

import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/auth_service.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/reset_sent_success.dart';

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
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => SuccessScreen(message: 'Email sent :)'),
        ),
      );
      print('Password reset email sent successfully.');
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: groupedBackgroundColor,
            largeTitle: const Text(
              'Reset Password',
              style: TextStyle(
                letterSpacing: -1.36,
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: 22, color: CupertinoColors.label.resolveFrom(context)),
            ),
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
                  borderRadius: BorderRadius.circular(10.0),
                  color: CupertinoColors.tertiarySystemBackground,
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
                color: accentColor,
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
