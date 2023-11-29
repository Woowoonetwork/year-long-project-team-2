// home_screen.dart
// a page that displays the post feeds
import 'package:FoodHood/Components/post_card.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components.dart'; // Ensure this is the correct path to component.dart
import '../Components/order_card.dart';
import '../Components/post_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
} // text controller for search bar

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController textController = TextEditingController();
  List<Widget> postCards = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<List<Widget>> fetchPosts() async {
    List<Widget> fetchedPostCards = [];
    List<String> documentNames = ['Test1', 'Test2'];

    for (String docName in documentNames) {
      try {
        Map<String, dynamic>? documentData = await readDocument(
          collectionName: 'post_details',
          docName: docName,
        );
        if (documentData != null) {
          print('Document data for $docName: $documentData');
          // Assuming 'Tags' is a comma-separated string
          List<String> tags = documentData['tag'].split(',');
          String title = documentData['Title'] ?? 'No Title';

          // Fetch user details (assuming 'UserId' is in documentData)
          String userId = documentData['UserId'] ?? 'Unknown';
          Map<String, dynamic>? userData = await readDocument(
            collectionName: 'user',
            docName: userId,
          );

          // Create a PostCard with fetched data
          var postCard = PostCard(
            title: title,
            tags: tags,
            firstname: userData?['firstName'] ?? 'Unknown',
            lastname: userData?['lastName'] ?? 'Unknown',
          );

          fetchedPostCards.add(postCard);
          fetchedPostCards
              .add(SizedBox(height: 16)); // For spacing between cards
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    return fetchedPostCards;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: <Widget>[
          buildMainNavigationBar(context, 'Discover'),
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

                SizedBox(height: 15),
                Expanded(
                  child: FutureBuilder<List<Widget>>(
                    future: fetchPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text("No Posts Available"));
                      }
                      return ListView(
                        children: snapshot.data!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
