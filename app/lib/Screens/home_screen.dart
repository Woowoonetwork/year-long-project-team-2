// home_screen.dart
// a page that displays the post feeds
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:FoodHood/firestore_service.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// feather icon
import 'package:feather_icons/feather_icons.dart';
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
  bool isLoading = true;
  final FocusNode _focusNode = FocusNode();
  String? post_detail_id;

  @override
  void initState() {
    super.initState();
    textController.addListener(_onSearchTextChanged);
    _loadInitialPosts();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // Call setState to trigger the UI update when the focus changes
    setState(() {});
  }

  void _loadInitialPosts() {
    setState(() {
      isLoading = true; // Start loading
    });

    postsSubscription = FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      var fetchedPostCards = await _processSnapshot(snapshot);
      setState(() {
        postCards = fetchedPostCards;
        isLoading = false; // Loading complete
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
          onTap: _onPostCardTap,
          postId: document.id,
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
    _focusNode.dispose();
  }

  void _onPostCardTap(String postId) {
    setState(() {
      post_detail_id = postId;
    });
    print(post_detail_id);
  }

  Future<List<Widget>> fetchPosts(String searchString) async {
    List<Widget> fetchedPostCards = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post_details')
          .orderBy('post_timestamp', descending: true)
          .get(); //query to display the post cards in a descending order by time

      for (var document in querySnapshot.docs) {
        Map<String, dynamic> documentData =
            document.data() as Map<String, dynamic>;

        String title = documentData['title'] ?? 'No Title'; //retrieving title
        List<String> tags =
            documentData['categories'].split(','); //retrieveing tags
        bool matchesSearchString = title.toLowerCase().contains(searchString) ||
            tags.any((tag) => tag
                .toLowerCase()
                .contains(searchString)); //search bar condition check

        // Check if the title contains the search string
        if (matchesSearchString) {
          List<Color> assignedColors = tags.map((tag) {
            tag = tag.trim();
            if (!tagColors.containsKey(tag)) {
              tagColors[tag] =
                  _getRandomColor(); // Assign a new color if not already assigned
            }
            return tagColors[tag]!;
          }).toList();

          DateTime createdAt;

          createdAt = (documentData['post_timestamp'] as Timestamp)
              .toDate(); //retrieving the time when the post is created

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
            onTap: _onPostCardTap,
            postId: document.id,
          );

          fetchedPostCards.add(postCard);
          fetchedPostCards.add(SizedBox(height: 16));
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
      backgroundColor: groupedBackgroundColor,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              buildMainNavigationBar(context, 'Discover'),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    _buildSearchBar(context),
                    SizedBox(height: 16),
                    _buildCategoryButtons(),
                    SizedBox(height: 16),
                    if (isLoading)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CupertinoActivityIndicator(),
                            SizedBox(height: 10),
                            Text('Loading',
                                style: TextStyle(
                                    color: CupertinoColors.secondaryLabel
                                        .resolveFrom(context))),
                          ],
                        ),
                      )
                    else
                      for (Widget postCard in postCards) postCard,
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    bool isFocused = _focusNode.hasFocus;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                suffixIcon: Icon(
                  FeatherIcons.x,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  size: 20,
                ),
                placeholderStyle: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                backgroundColor: CupertinoColors.tertiarySystemBackground,
                controller: textController,
                placeholder: 'Search',
                onChanged: (String value) {
                  _onSearchTextChanged();
                },
              ),
            ),
            // Only include the SizedBox and filter button if there is no text.
            if (!isFocused) ...[
              SizedBox(width: 10),
              _buildFilterButton(),
            ],
          ],
        ),
      ),
    );
  }

  void _onSearchTextChanged() async {
    setState(() {});

    // Fetch the post cards based on the search text.
    var fetchedPostCards = await fetchPosts(textController.text.toLowerCase());

    // Then, update the UI once the fetch operation is complete.
    setState(() {
      postCards = fetchedPostCards;
    });
  }

  Widget _buildFilterButton() {
    return Container(
      height: 37,
      width: 37,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(FeatherIcons.filter,
            color: CupertinoColors.secondaryLabel.resolveFrom(
                context), // Use the label color from the current theme (light or dark
            size: 20),
        onPressed: () {
          // Filter button action
        },
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          spacing: 8.0, // Space between each button
          children: <Widget>[
            _buildCategoryButton('All', accentColor),
            _buildCategoryButton('Vegan', yellow),
            _buildCategoryButton('Italian', orange),
            _buildCategoryButton('Halal', blue),
            _buildCategoryButton('Vegetarian', babyPink),
            _buildCategoryButton('Indian', orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title, Color color) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 61, // Set the minimum width
          maxHeight: 37, // Set the height
        ),
        child: CupertinoButton(
          child: Text(title,
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  letterSpacing: -.8,
                  fontWeight:
                      FontWeight.w600)), // Adjust the font style as needed
          color: color,
          padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 6), // Adjust the padding for proper pill shape
          borderRadius: BorderRadius.circular(
              40), // This value might need to be half of the total vertical padding for a perfect pill shape
          onPressed: () {
            // Category button action
          },
        ));
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      bottom: 116.0,
      right: 16.0,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey3,
              spreadRadius: 2, // Spread radius
              blurRadius: 10, // Blur radius
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
          shape:
              BoxShape.circle, // To keep the container circular like the button
        ),
        child: CupertinoButton(
          onPressed: () {
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => CreatePostScreen()));
          },
          child:
              Icon(FeatherIcons.plus, color: CupertinoColors.white, size: 30),
          color: accentColor,
          padding: EdgeInsets.all(16.0),
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
    );
  }

//Method for getting when the post was created
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

//get a random colour for the tags . Choosing a colour between four
  Color _getRandomColor() {
    var random = math.Random();
    var colors = [
      yellow,
      orange,
      blue,
      babyPink,
    ];
    return colors[random.nextInt(colors.length)];
  }
}
