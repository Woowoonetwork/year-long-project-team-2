// settings_screen.dart
// A page that allows a user to modify their app's settings.

import 'package:flutter/cupertino.dart';
import '../Components/profile_card.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1.0),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Color.fromRGBO(238, 238, 238, 1.0),
        middle: Text(
          'Settings',
          style: TextStyle(
            letterSpacing: -1.36,
            fontSize: 24.0,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.arrow_left, color: CupertinoColors.black),
          onPressed: () async {
            // add onPressed functionality
            Navigator.of(context).pop();
          },
        ),
        border: Border(bottom: BorderSide.none),
      ),
      
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          children: [
            //Display the profile
            ProfileCard(),

            SizedBox(height: 50),

            // Push Notifications
            Padding(
              padding: EdgeInsets.only(left: 24.0, right:17.0),
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

            // Add more settings rows as needed

          ],
        ),
      ),
    );
  }
}
