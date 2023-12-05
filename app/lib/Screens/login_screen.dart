// login_screen.dart
// a page that allows the user to log in to the app

import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import '../components.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogInScreen extends StatelessWidget {
  final TextEditingController emailController =
      TextEditingController(); // text controller for email
  final TextEditingController passwordController =
      TextEditingController(); // text controller for password

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      navigationBar: buildBackNavigationBar(context),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildLoginForm(context),
                buildBottomGroup(context), // New method for bottom group
              ],
            ),
          ),
        ),
      ),
    );
  }

// Extract the bottom group into its own method
  Widget buildBottomGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildContinueButton(context, 'Continue', accentColor,
            CupertinoColors.white), // Continue button
        const SizedBox(height: 20),

        buildCenteredText('or', 14, FontWeight.w600),
        const SizedBox(height: 20),
        buildGoogleSignInButton(context),
        const SizedBox(height: 20),
        buildSignUpText(
            context, "Don't have an account? ", 'Sign up', '/signup'),
      ],
    );
  }

  // Log in form
  Column buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildText('Log in', 34, FontWeight.w600), // Log in text
        const SizedBox(height: 50),
        buildCupertinoTextField('Email Address', emailController, false,
            context), // Email text field
        const SizedBox(height: 20),
        buildCupertinoTextField('Password', passwordController, true,
            context), // Password text field
        const SizedBox(height: 20),
        buildTextButton(
            'Forgot Password?',
            Alignment.centerRight,
            const Color(0xFF337586),
            12,
            FontWeight.w500), // Forgot password text
        const SizedBox(height: 20),
      ],
    );
  }

  // Continue button
  Widget buildContinueButton(BuildContext context, String text,
      Color backgroundColor, Color textColor) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return CupertinoButton(
      onPressed: () async {
        try {
          // ignore: unused_local_variable
          final UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          print("logged in");

          //Navigate to the home screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/nav',
            (route) => false,
            arguments: {'selectedIndex': 0},
          );
          
        } catch (e) {
          // Handle login errors (e.g., wrong credentials).
          print('Login error: $e'); //prints error
        }
      },
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
