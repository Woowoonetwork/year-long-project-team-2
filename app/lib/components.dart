// component.dart
// Themeing components

import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';

class Styles {
  static TextStyle titleStyle = TextStyle(
    color: CupertinoColors.label,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.36,
  );

  static TextStyle descriptionStyle = TextStyle(
    color: CupertinoColors.secondaryLabel,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.80,
  );

  static TextStyle buttonTextStyle = TextStyle(
    color: CupertinoColors.systemBackground,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.90,
  );

  static TextStyle signUpTextStyle = TextStyle(
    color: accentColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.20,
  );

  static TextStyle signUpLinkStyle = TextStyle(
    color: secondaryColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.20,
  );
}

CupertinoNavigationBar buildNavigationBar(BuildContext context) {
  return CupertinoNavigationBar(
    backgroundColor: groupedBackgroundColor,
    border: Border(
      bottom: BorderSide.none,
    ),
    leading: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.back, color: Color(0xFF337586)),
      onPressed: () => Navigator.pop(context),
    ),
  );
}

CupertinoSliverNavigationBar buildMainNavigationBar(
    BuildContext context, String title) {
  return CupertinoSliverNavigationBar(
    backgroundColor: groupedBackgroundColor,
    border: const Border(
      bottom: BorderSide.none,
    ),
    largeTitle: Text(
      title,
      style: TextStyle(
        letterSpacing: -1.1,
      ),
    ),
    stretch: true, // Enable stretch behavior
  );
}

CupertinoNavigationBar buildBackNavigationBar(BuildContext context) {
  return CupertinoNavigationBar(
    backgroundColor: groupedBackgroundColor,
    border: const Border(
      bottom: BorderSide.none,
    ),
    leading: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.back,
          color: CupertinoDynamicColor.resolve(CupertinoColors.label, context)),
      onPressed: () => Navigator.pop(context),
    ),
  );
}

Widget buildGoogleSignInButton(BuildContext context) {
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      border: Border.all(
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: CupertinoButton(
      onPressed: () {},
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
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCupertinoTextField(String placeholder,
    TextEditingController controller, bool obscureText, BuildContext context) {
  return CupertinoTextField(
    controller: controller,
    obscureText: obscureText,
    placeholder: placeholder,
    padding: EdgeInsets.all(16.0),
    placeholderStyle: TextStyle(
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    decoration: BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

Widget buildText(String text, double fontSize, FontWeight fontWeight) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Widget buildTextButton(String text, Alignment alignment, Color color,
    double fontSize, FontWeight fontWeight) {
  return Align(
    alignment: alignment,
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );
}

Widget buildSignUpText(
    BuildContext context, String description, String link, String destination) {
  return Align(
    alignment: Alignment.center,
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, destination),
      child: RichText(
        text: TextSpan(
          text: description,
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          children: <TextSpan>[
            TextSpan(
              text: link,
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildCenteredText(String text, double fontSize, FontWeight fontWeight) {
  return Center(
    child: buildText(text, fontSize, fontWeight),
  );
}
