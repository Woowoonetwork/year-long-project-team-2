// home_screen.dart
// a page that displays the post feeds
import 'package:FoodHood/Components/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: CupertinoSearchTextField(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          style: const TextStyle(fontSize: 18),
                          controller: textController,
                          placeholder: 'Search',
                        ),
                      ),
                      SizedBox(
                          width:
                              10), // Space between search bar and filter button
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 231, 228, 228),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(CupertinoIcons.ellipsis_vertical,
                                size: 24),
                            onPressed: () {
                              // Filter button action
                            },
                          ),
                        ),
                      ),
                    ],
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
                            'All',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromARGB(255, 21, 136, 102),
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
                            'Vegan',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromARGB(255, 214, 118, 131),
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
                            'Italian',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromARGB(255, 243, 28, 179),
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
                            'Halal',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromARGB(255, 116, 186, 243),
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
                            'Vegetarian',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromRGBO(233, 118, 11, 1),
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
                            'Indian',
                            style: TextStyle(fontSize: 12), // Smaller font size
                          ),
                          color: Color.fromARGB(255, 86, 204, 240),
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
