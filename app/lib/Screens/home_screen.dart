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
import 'package:cloud_firestore/cloud_firestore.dart';

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
    textController.addListener(_onSearchTextChanged);
    _loadInitialPosts();
  }

  void _loadInitialPosts() async {
    var fetchedPostCards = await fetchPosts('');
    setState(() {
      postCards = fetchedPostCards;
    });
  }

  @override
  void dispose() {
    textController.removeListener(_onSearchTextChanged);
    textController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() async {
    var fetchedPostCards = await fetchPosts(textController.text.toLowerCase());
    setState(() {
      postCards = fetchedPostCards; // Update the UI with the filtered list
    });
  }

  Future<List<Widget>> fetchPosts(String searchString) async {
    List<Widget> fetchedPostCards = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post_details')
          .orderBy('post_timestamp', descending: true)
          .get();

      for (var document in querySnapshot.docs) {
        Map<String, dynamic> documentData =
            document.data() as Map<String, dynamic>;

        if (documentData != null) {
          String title = documentData['title'] ?? 'No Title';

          // Check if the title contains the search string
          if (title.toLowerCase().contains(searchString)) {
            print('Document data for $documentData: $documentData');
            // Assuming 'Tags' is a comma-separated string
            List<String> tags = documentData['category'].split(',');
            DateTime createdAt;

            createdAt = (documentData['post_timestamp'] as Timestamp).toDate();

            // Fetch user details (assuming 'UserId' is in documentData)
            String userId = documentData['user_id'] ?? 'Unknown';
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
              timeAgo: timeAgoSinceDate(createdAt),
            );

            fetchedPostCards.add(postCard);
            fetchedPostCards
                .add(SizedBox(height: 16)); // For spacing between cards
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
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
                          onChanged: (String value) {
                            _onSearchTextChanged(); // Call this method whenever the text changes
                          },
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
                  child: ListView(
                    children: postCards,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 8) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}'; // Return the date
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} mins ago';
    } else {
      return 'Just now';
    }
  }
}
