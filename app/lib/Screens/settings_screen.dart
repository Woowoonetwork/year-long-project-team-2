// settings_screen.dart
// A page that allows a user to modify their app's settings.

import 'package:flutter/cupertino.dart';
import '../Components/profile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        middle: const Text(
          'Settings',
          style: TextStyle(
            letterSpacing: -1.36,
            fontSize: 24.0,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.arrow_left, color: CupertinoColors.black),
          onPressed: () async {
            // add onPressed functionality
            Navigator.of(context).pop();
          },
        ),
        border: const Border(bottom: BorderSide.none),
      ),
      
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
        child: Column(
          children: [
            // Display the profile
            ProfileCard(userid: FirebaseAuth.instance.currentUser?.uid ?? ''), // Pass userid here

            SizedBox(height: 50),

            // Push Notifications
            Padding(
              padding: EdgeInsets.only(left: 20.0, right:17.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Push Notifications',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  CupertinoSwitch(
                    activeColor: Color.fromRGBO(51, 117, 134, 1.0),
                    value: pushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushNotificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Accessibility Button
            Padding(
              padding: EdgeInsets.all(17.0),
              child: AccessibilityButton(),
            ),
            
            // Help Button
            Padding(
              padding: EdgeInsets.only(left:17.0, right: 17.0),
              child: HelpButton(),
            ),

            // Sign out Button
            Padding(
              padding: EdgeInsets.all(17.0),
              child: SignOutButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessibilityButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        // Add the button functionality here
      },
      color: CupertinoColors.secondarySystemGroupedBackground,
      borderRadius: BorderRadius.circular(23),
      padding: EdgeInsets.all(16.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.eye, color: CupertinoColors.black),
              SizedBox(width: 15.0), // Adjust the spacing between icon and text
              Text(
                'Accessibility',
                style: TextStyle(
                  fontSize: 18.0,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          Icon(
            CupertinoIcons.forward,
            color: CupertinoColors.black,
          ),
        ],
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        // Add the button functionality here
      },
      color: CupertinoColors.secondarySystemGroupedBackground,
      borderRadius: BorderRadius.circular(23),
      padding: EdgeInsets.all(16.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.question_circle, color: CupertinoColors.black),
              SizedBox(width: 15.0), // Adjust the spacing between icon and text
              Text(
                'Help',
                style: TextStyle(
                  fontSize: 18.0,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          Icon(
            CupertinoIcons.forward,
            color: CupertinoColors.black,
          ),
        ],
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () async {
        showSignOutConfirmationDialog(context);
      },
      color: CupertinoColors.secondarySystemGroupedBackground,
      borderRadius: BorderRadius.circular(23),
      padding: EdgeInsets.all(16.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.square_arrow_right, color: CupertinoColors.black),
              SizedBox(width: 15.0), // Adjust the spacing between icon and text
              Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 18.0,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          Icon(
            CupertinoIcons.forward,
            color: CupertinoColors.black,
          ),
        ],
      ),
    );
  }

  // Function to show the confirmation dialog
  void showSignOutConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                // Sign out
                await FirebaseAuth.instance.signOut();
                // Navigate to the welcome screen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              isDestructiveAction: true,
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
