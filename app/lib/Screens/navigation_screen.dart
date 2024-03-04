import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
//import 'package:FoodHood/Screens/browse_screen.dart';
import 'package:FoodHood/Screens/account_screen.dart';
import 'package:FoodHood/Screens/browse_screen.dart';
import 'package:FoodHood/Screens/saved_screen.dart';
import 'package:flutter/services.dart';

class NavigationScreen extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationScreen({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          HapticFeedback.selectionClick(); // Adding haptic feedback on tap
          onItemTapped(index);
        },
        iconSize: 24,
        backgroundColor:
            CupertinoDynamicColor.resolve(groupedBackgroundColor, context)
                .withOpacity(0.8),
        border: Border(top: BorderSide.none),
        activeColor: accentColor.color,
        inactiveColor: CupertinoColors.label
            .resolveFrom(context)
            .withOpacity(0.6), // inactive tab color
        items: [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.compass),
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.map),
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.bookmark),
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.user),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeScreen();
          case 1:
            return BrowseScreen();
          case 2:
            return SavedScreen();
          case 3:
            return AccountScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}
