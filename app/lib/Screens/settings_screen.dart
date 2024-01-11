import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/components.dart';
import 'package:flutter/cupertino.dart';
import '../components/profile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter_switch/flutter_switch.dart';

// Constants for styling
const double _defaultPadding = 20.0;
const double _defaultMargin = 16.0;
const double _defaultFontSize = 16.0;
const double _iconSize = 22.0;
const double _spacing = 15.0;
const double _buttonBorderRadius = 16.0;
const double _switchHeight = 29.0;
const double _switchWidth = 52.0;
const double _switchPadding = 4.0;
const double _switchToggleSize = 22.0;
const double _switchBorderRadius = 100.0;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Settings', style: TextStyle(letterSpacing: -1.34)),
            border: Border(bottom: BorderSide.none),
            backgroundColor: groupedBackgroundColor,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: _iconSize, color: CupertinoColors.label.resolveFrom(context)),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 10),
                ProfileCard(),
                SizedBox(height: 10),
                _buildSettingOption('Push Notifications', _buildSwitch()),
                SizedBox(height: 16),
                _buildSettingButton('Accessibility', FeatherIcons.eye, () {}),
                SizedBox(height: 14),
                _buildSettingButton('Help', FeatherIcons.helpCircle, () {}),
                SizedBox(height: 14),
                _buildSettingButton('Sign out', FeatherIcons.logOut, () {
                  showSignOutConfirmationSheet(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor: groupedBackgroundColor,
      middle: Text('Settings'),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(FeatherIcons.arrowLeft,
            size: _iconSize, color: CupertinoColors.label.resolveFrom(context)),
      ),
      border: const Border(bottom: BorderSide.none),
    );
  }

  Widget _buildSettingOption(String title, Widget trailing) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: _defaultPadding, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w600)),
          trailing
        ],
      ),
    );
  }

  Widget _buildSwitch() {
    return FlutterSwitch(
      height: _switchHeight,
      width: _switchWidth,
      padding: _switchPadding,
      toggleSize: _switchToggleSize,
      borderRadius: _switchBorderRadius,
      activeColor: accentColor,
      value: pushNotificationsEnabled,
      onToggle: (value) => setState(() => pushNotificationsEnabled = value),
    );
  }

  Widget _buildSettingButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _defaultMargin),
      child: CupertinoButton(
        onPressed: onPressed,
        color: CupertinoColors.tertiarySystemBackground,
        borderRadius: BorderRadius.circular(_buttonBorderRadius),
        padding: EdgeInsets.symmetric(
            horizontal: _defaultPadding, vertical: _defaultPadding / 1.25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: _iconSize,
                    color: CupertinoColors.label.resolveFrom(context)),
                SizedBox(width: _spacing),
                Text(title,
                    style: TextStyle(
                        fontSize: _defaultFontSize,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.label.resolveFrom(context))),
              ],
            ),
            Icon(FeatherIcons.chevronRight,
                color: CupertinoColors.label.resolveFrom(context)),
          ],
        ),
      ),
    );
  }

  void showSignOutConfirmationSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Are you sure you want to Sign out?',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                'Sign Out',
                style: TextStyle(
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop(); // Close the action sheet
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the action sheet
            },
          ),
        );
      },
    );
  }
}
