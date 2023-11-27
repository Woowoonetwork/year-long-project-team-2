import 'package:FoodHood/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
//import 'package:FoodHood/Screens/browse_screen.dart';
//import 'package:FoodHood/Screens/new_post_screen.dart';
import 'package:FoodHood/Screens/account_screen.dart';

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
        onTap: onItemTapped,
        iconSize: 24,
        height: 60,
        border: Border(top: BorderSide.none),
        activeColor: Color(0xFF337586), // active tab color
        inactiveColor: CupertinoColors.secondaryLabel, // inactive tab color
        items: [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.home),
            label: '', // label is now empty
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.map),
            label: '', // label is now empty
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.plusSquare),
            label: '', // label is now empty
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.archive),
            label: '', // label is now empty
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.user),
            label: '', // label is now empty
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeScreen();
          // case 1:
          //   return BrowseScreen();
          case 2:
            //return CreatePostScreen();
          // case 3:
          //   return SavedScreen();  
          case 4:
            return AccountScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}
