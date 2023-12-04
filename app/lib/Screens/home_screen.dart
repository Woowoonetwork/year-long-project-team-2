// home_screen.dart
// a page that displays the post feeds
import 'package:FoodHood/Components/post_card.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components.dart'; // Ensure this is the correct path to component.dart
import '../Components/order_card.dart';
import '../Components/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
} // text controller for search bar

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController textController = TextEditingController();
  List<Widget> postCards = [];
  Map<String, Color> tagColors = {};
  StreamSubscription<QuerySnapshot>? postsSubscription; // Add this line

  @override
  void initState() {
    super.initState();
    textController.addListener(_onSearchTextChanged);
    _loadInitialPosts();
  }

  void _loadInitialPosts() {
    // Set up a live listener
    postsSubscription = FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      // Note the 'async' keyword here
      var fetchedPostCards =
          await _processSnapshot(snapshot); // Await the result
      setState(() {
        postCards = fetchedPostCards; // Assign the awaited result to postCards
      });
    });
  }

  Future<List<Widget>> _processSnapshot(QuerySnapshot snapshot) async {
    List<Widget> fetchedPostCards = [];
    try {
      for (var document in snapshot.docs) {
        Map<String, dynamic> documentData =
            document.data() as Map<String, dynamic>;

        String title = documentData['title'] ?? 'No Title';
        List<String> tags = documentData['categories'].split(',');

        // Assign colors to tags
        List<Color> assignedColors = tags.map((tag) {
          tag = tag.trim();
          if (!tagColors.containsKey(tag)) {
            tagColors[tag] =
                _getRandomColor(); // Assign a new color if not already assigned
          }
          return tagColors[tag]!;
        }).toList();

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
          tagColors: assignedColors,
          firstname: userData?['firstName'] ?? 'Unknown',
          lastname: userData?['lastName'] ?? 'Unknown',
          timeAgo: timeAgoSinceDate(createdAt),
        );

        fetchedPostCards.add(postCard);
        fetchedPostCards.add(SizedBox(height: 16)); // For spacing between cards
      }
    } catch (e) {
      print('Error processing snapshot: $e');
    }
    return fetchedPostCards;
  }

  @override
  void dispose() {
    textController.removeListener(_onSearchTextChanged);
    textController.dispose();
    super.dispose();
  }

  // void _executeSearch() async {
  //   var fetchedPostCards = await fetchPosts(textController.text.toLowerCase());
  //   setState(() {
  //     postCards = fetchedPostCards;
  //   });
  // }
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
          List<String> tags = documentData['categories'].split(',');
          bool matchesSearchString =
              title.toLowerCase().contains(searchString) ||
                  tags.any((tag) => tag.toLowerCase().contains(searchString));

          // Check if the title contains the search string
          if (matchesSearchString) {
            print('Document data for $documentData: $documentData');
            // Assuming 'Tags' is a comma-separated string
            List<Color> assignedColors = tags.map((tag) {
              tag = tag.trim();
              if (!tagColors.containsKey(tag)) {
                tagColors[tag] =
                    _getRandomColor(); // Assign a new color if not already assigned
              }
              return tagColors[tag]!;
            }).toList();

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
              tagColors: assignedColors,
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
      child: Stack(
        children: [
          CustomScrollView(
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
                          // CupertinoButton(
                          //   padding: EdgeInsets.zero,
                          //   child: Icon(CupertinoIcons.search, size: 24),
                          //   onPressed: _executeSearch,
                          // ),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromARGB(255, 21, 136, 102),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromARGB(255, 214, 118, 131),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromARGB(255, 243, 28, 179),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromARGB(255, 116, 186, 243),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromRGBO(233, 118, 11, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
                                style: TextStyle(
                                    fontSize: 12), // Smaller font size
                              ),
                              color: Color.fromARGB(255, 86, 204, 240),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
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
          Positioned(
            bottom: 100.0,
            right: 30.0,
            child: CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => CreatePostScreen()));
              },
              child: Icon(CupertinoIcons.add),
              color: Color.fromRGBO(51, 117, 134, 1.0),
              padding: EdgeInsets.all(18.0), // Adjust padding to control size
              borderRadius:
                  BorderRadius.circular(40.0), // Adjust the radius as needed
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

  Color _getRandomColor() {
    var random = math.Random();
    var colors = [
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
      Colors.pinkAccent[100]!,
      Colors.yellowAccent[100]!
    ];
    return colors[random.nextInt(colors.length)];
  }
}
