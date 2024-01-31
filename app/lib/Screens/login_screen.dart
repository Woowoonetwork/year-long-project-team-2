// login_screen.dart
// a page that allows the user to log in to the app

import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/reset_pwd_screen.dart';
import 'package:flutter/cupertino.dart';
import '../components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                Column(
                  children: [
                    buildLoginForm(context),
                  ],
                ),
                Column(
                  children: [
                    buildBottomGroup(context),
                  ],
                ),
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
        const SizedBox(height: 16),
        buildCenteredText('or', 12, FontWeight.w600),
        const SizedBox(height: 16),
        buildGoogleSignInButton(context),
        const SizedBox(height: 16),
        buildAppleSignInButton(context),
        const SizedBox(height: 26),
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
            context, [AutofillHints.email]),// Email text field
        const SizedBox(height: 20),
        buildCupertinoTextField('Password', passwordController, true,
            context, [AutofillHints.password]), // Password text field
        const SizedBox(height: 20),
        buildTextButton(
            context,
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
  // Continue button with loading indicator
  Widget buildContinueButton(BuildContext context, String text,
      Color backgroundColor, Color textColor) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return CupertinoButton(
      onPressed: () async {
        try {
          showLoadingDialog(context); // Show loading dialog
          final UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          print("logged in");
          Navigator.of(context).pop(); // Dismiss loading dialog

          // Navigate to the home screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/nav',
            (route) => false,
            arguments: {'selectedIndex': 0},
          );
        } catch (e) {
          Navigator.of(context).pop(); // Dismiss loading dialog on error
          String errorMessage = e.toString();
          errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]\s'), '');

          // Display formatted error in Cupertino alert dialog
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Login Error'),
                content: Text("Your email or password is incorrect."),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          print('Login error: $errorMessage');
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

  // Update the buildTextButton method to include onPressed callback
  Widget buildTextButton(BuildContext context, String text, Alignment alignment,
      Color color, double fontSize, FontWeight fontWeight) {
    return GestureDetector(
      onTap: () {
        // Add your logic for the "Forgot Password?" action here
        // For example, you can navigate to a password reset screen
        //Navigator.pushNamed(context, '/reset_password');
        Navigator.of(context).push(
            CupertinoPageRoute(builder: (context) => ForgotPasswordScreen()));
      },
      child: Align(
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Widget buildAppleSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: CupertinoButton(
        onPressed: () async {
          try {
            await signInWithApple();
            // Navigate to home or desired screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/nav',
              (route) => false,
              arguments: {'selectedIndex': 0},
            );
          } catch (e) {
            // Handle exceptions
            print('Apple Sign-In error: $e');
          }
        },
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(14),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/apple.png', width: 16, height: 16),
            const SizedBox(width: 8),
            Text(
              'Sign in with Apple',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoogleSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey2, context),
          width: 0.6,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CupertinoButton(
        onPressed: () async {
          try {
            await signInWithGoogle();
            // Navigate to home or desired screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/nav',
              (route) => false,
              arguments: {'selectedIndex': 0},
            );
          } catch (e) {
            // Handle exceptions like user cancellation or network issues
            print('Google Sign-In error: $e');
          }
        },
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.tertiarySystemBackground, context),
        borderRadius: BorderRadius.circular(14),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google.png', width: 20, height: 20),
            const SizedBox(width: 2),
            Text(
              'Sign in with Google',
              style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label, context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show a loading dialog
  void showLoadingDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: 
            //indicator and the text below it
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 24),
                Text(
                  'Logging in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
