// home_screen.dart
// a page that displays the post feeds
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../components.dart'; // Ensure this is the correct path to component.dart
import '../Components/order_card.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController textController =
      TextEditingController(); // text controller for search bar

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground, // background color
      child: CustomScrollView(
        slivers: <Widget>[
          buildMainNavigationBar(context, 'Discover'), // navigation bar
          SliverFillRemaining(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoSearchTextField(
                    // search bar
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    style: const TextStyle(fontSize: 18),
                    controller: textController,
                    placeholder: 'Search',
                  ),
                ),
                SizedBox(height: 16), // Add some spacing before the text
                CupertinoButton(
                  child: Text('Log Out'),
                  color: CupertinoColors
                      .activeBlue, // Choose a color for your button
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Now sign in again to refresh the user data
                  },
                ),

                OrderCard()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
