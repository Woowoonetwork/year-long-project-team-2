// home_screen.dart
// a page that displays the post feeds
import 'package:FoodHood/Components/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../components.dart'; // Ensure this is the correct path to component.dart
import '../Components/order_card.dart';
import '../Components/post_card.dart';

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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoButton(
                          child: Text(
                            'Button 1',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: CupertinoColors.activeBlue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            // Button 1 action
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoButton(
                          child: Text(
                            'Button 2',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: CupertinoColors.activeBlue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            // Button 2 action
                          },
                        ),
                      ),
                      // Add more buttons as needed
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoButton(
                          child: Text(
                            'Button 3',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: CupertinoColors.activeBlue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            // Button 2 action
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoButton(
                          child: Text(
                            'Button 4',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: CupertinoColors.activeBlue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            // Button 2 action
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CupertinoButton(
                          child: Text(
                            'Button 5',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: CupertinoColors.activeBlue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () {
                            // Button 2 action
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  child: Text('Log Out'),
                  color: CupertinoColors
                      .activeBlue, // Choose a color for your button
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Now sign in again to refresh the user data
                  },
                ),

                PostCard()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
