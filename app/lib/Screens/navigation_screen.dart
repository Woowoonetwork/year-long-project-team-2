import 'package:FoodHood/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Screens/account_screen.dart';
import 'package:FoodHood/Screens/create_post.dart';

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
        height: 55,
        iconSize: 20, // Reduced icon size for compactness
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        activeColor: Color(0xFF337586), // active tab color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.home, size: 20), // Adjusted icon size
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.map, size: 20), // Adjusted icon size
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.plusSquare, size: 20), // Adjusted icon size
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.archive, size: 20), // Adjusted icon size
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FeatherIcons.user, size: 20), // Adjusted icon size
            label: '',
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
            return CreatePostScreen();
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
