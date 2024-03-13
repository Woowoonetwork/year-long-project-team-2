import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:FoodHood/Screens/account_screen.dart';
import 'package:FoodHood/Screens/browse_screen.dart';
import 'package:FoodHood/Screens/bookmark_screen.dart';

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
        activeColor: accentColor.resolveFrom(context),
        inactiveColor:
            CupertinoColors.label.resolveFrom(context).withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Home",
              child: Icon(CupertinoIcons.rectangle_stack),
            ),
            activeIcon: Semantics(
              label: "Home Active",
              child: Icon(CupertinoIcons.rectangle_stack_fill),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Browse",
              child: Icon(CupertinoIcons.compass),
            ),
            activeIcon: Semantics(
              label:
                  "Browse Active", // Screen reader label for active browse icon
              child: Icon(CupertinoIcons.compass_fill),
            ),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Bookmarks",
              child: Icon(CupertinoIcons.bookmark),
            ),
            activeIcon: Semantics(
              label: "Bookmarks Active",
              child: Icon(CupertinoIcons.bookmark_fill),
            ),
            label: "Bookmarks",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              label: "Account",
              child: Icon(CupertinoIcons.person),
            ),
            activeIcon: Semantics(
              label: "Account Active",
              child: Icon(CupertinoIcons.person_fill),
            ),
            label: "Account",
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
            return BookmarkScreen();
          case 3:
            return AccountScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}
