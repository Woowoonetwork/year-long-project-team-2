import 'package:flutter/cupertino.dart';
import 'orders_sheet.dart'; // Make sure this path is correct
import '../Components/profile_card.dart'; // Make sure this path is correct
import 'package:FoodHood/Screens/settings_screen.dart';

class AccountScreen extends StatelessWidget {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            largeTitle: Text(
              'Account',
              style: TextStyle(
                letterSpacing: -1.36,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'Orders',
                style: TextStyle(
                  color: Color(0xFF337586), // Your custom color
                ),
              ),
              onPressed: () => showPastOrdersSheet(context),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFF337586), // Your custom color
                ),
              ),
              onPressed: () {
                // TODO: Add your onPressed functionality here
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            border: Border(bottom: BorderSide.none),
          ),
          SliverToBoxAdapter(
            child: ProfileCard(), // Add the ProfileCard to the list of slivers
          ),
          // Add more Sliver widgets if needed
        ],
      ),
    );
  }
}
