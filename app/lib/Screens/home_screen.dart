// home_screen.dart
<<<<<<< HEAD
// a page that displays the post feeds
import 'package:FoodHood/Components/post_card.dart';
=======
>>>>>>> master
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components.dart'; // Ensure this is the correct path to component.dart
<<<<<<< HEAD
import '../Components/order_card.dart';
import '../Components/post_card.dart';
=======
import 'public_page.dart'; // Import the PublicPage screen
>>>>>>> master

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
                          height: 38,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 221, 217, 217),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(CupertinoIcons.sort_down, size: 24),
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
<<<<<<< HEAD
                SizedBox(height: 16),

                PostCard()
=======
                SizedBox(height: 16), // Add some spacing before the new button
                CupertinoButton(
                  child: Text('Flint Carmintail'),
                  color: CupertinoColors.systemGreen, // Choose a color for your button
                  onPressed: () {
                    // Navigate to the PublicPage screen
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PublicPage(),
                      ),
                    );
                  },
                ),
>>>>>>> master
              ],
            ),
          ),
        ],
      ),
    );
  }
}
