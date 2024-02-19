import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';

const double _defaultFontSize = 16.0;
const double _defaultPostCountFontSize = 14.0;

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<String> savedPostIds = [];
  List<String> filteredPostIds = []; // Added for filtered post IDs
  bool isLoading = true;
  StreamSubscription? _savedPostsSubscription;

  late double _textScaleFactor;
  late double adjustedFontSize;
  late double adjustedPostCountFontSize;

  @override
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(),
          if (isLoading)
            _buildLoadingSliver()
          else if (filteredPostIds.isEmpty) // Use filteredPostIds here
            _buildNoSavedPostsMessage()
          else
            _buildSavedPostsList(filteredPostIds), // Use filteredPostIds here
        ],
      ),
    );
  }

  void initState() {
    super.initState();
    _fetchSavedPosts();
    _listenForSavedPosts();
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
  }

  void _updateAdjustedFontSize() {
    adjustedFontSize = _defaultFontSize * _textScaleFactor;
    adjustedPostCountFontSize = _defaultPostCountFontSize * _textScaleFactor;
  }

  Future<void> _fetchSavedPosts() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    var document =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (document.exists && document.data()!.containsKey('saved_posts')) {
      savedPostIds = List<String>.from(document.data()!['saved_posts']);
      filteredPostIds.clear(); // Clear previous data
      await Future.forEach(savedPostIds, (String postId) async {
        var postDoc = await FirebaseFirestore.instance
            .collection('post_details')
            .doc(postId)
            .get();
        if (!postDoc.exists || !postDoc.data()!.containsKey('reserved_by')) {
          filteredPostIds.add(postId); // Add post if it's not reserved
        }
      });
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _listenForSavedPosts() {
    _savedPostsSubscription = FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .snapshots()
        .listen(
      (document) {
        if (mounted) {
          if (document.exists && document.data()!.containsKey('saved_posts')) {
            setState(() {
              savedPostIds = List<String>.from(document.data()!['saved_posts']);
              isLoading = false;
            });
          }
        }
      },
      onError: (error) => print("Error listening to saved posts: $error"),
    );
  }

  @override
  void dispose() {
    _savedPostsSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  CupertinoSliverNavigationBar _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: groupedBackgroundColor,
      largeTitle: Text('Bookmarks'),
      border: Border(bottom: BorderSide.none),
      stretch: true,
    );
  }

  SliverFillRemaining _buildLoadingSliver() {
    return SliverFillRemaining(
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  SliverList _buildSavedPostsList(List<String> savedPostIds) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index < savedPostIds.length) {
            return _buildPostItem(context, savedPostIds[index]);
          } else if (index == savedPostIds.length && savedPostIds.isNotEmpty) {
            return Column(
              children: [
                _buildPostCountIndicator(), // Now dynamically reflects the filtered list size
                SizedBox(height: 100),
              ],
            );
          }
          return null;
        },
        childCount: savedPostIds.isEmpty
            ? 0
            : savedPostIds.length +
                1, // Account for the dynamically added post count indicator
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, String postId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('post_details')
          .doc(postId)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // Check for data existence and handle null or error states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CupertinoActivityIndicator()); // Show a loading indicator while waiting
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SizedBox.shrink(); // If no data exists, return an empty space
        }

        // Explicitly cast the snapshot data to a Map<String, dynamic>
        var postData = snapshot.data!.data() as Map<String, dynamic>?;
        if (postData == null || postData.containsKey('reserved_by')) {
          // If postData is null or contains 'reserved_by', do not display it
          return SizedBox.shrink();
        }

        // Fetch the user data for the post
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(postData['user_id'] as String)
              .get(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CupertinoActivityIndicator()); // Show a loading indicator while waiting
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return SizedBox
                  .shrink(); // If no user data exists, return an empty space
            }

            // Explicitly cast the userSnapshot data to a Map<String, dynamic>
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            if (userData == null) {
              return SizedBox
                  .shrink(); // If userData is null, return an empty space
            }

            // Now that we have both postData and userData, we can build and return the post card widget
            return _buildPostCard(postData, userData, postId);
          },
        );
      },
    );
  }

  SliverFillRemaining _buildNoSavedPostsMessage() {
    return SliverFillRemaining(
      hasScrollBody: false, // Prevents the message from being scrollable
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(FeatherIcons.bookmark,
                size: 42,
                color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            SizedBox(height: 10),
            Text(
              'No Bookmarks Found',
              style: TextStyle(
                fontSize: adjustedFontSize,
                letterSpacing: -0.6,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// Updated _buildPostCard method to include postId as a parameter
  Widget _buildPostCard(Map<String, dynamic> postData,
      Map<String, dynamic> userData, String postId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: PostCard(
        imageLocation: postData['image_url'] ?? '',
        title: postData['title'] ?? 'No Title',
        tags: (postData['categories'] as String)
            .split(',')
            .map((tag) => tag.trim())
            .toList(),
        tagColors: _assignedColors(),
        firstname: userData['firstName'] ?? 'Unknown',
        lastname: userData['lastName'] ?? 'Unknown',
        timeAgo: timeAgoSinceDate(
            (postData['post_timestamp'] as Timestamp).toDate()),
        onTap: _onPostCardTap, // Using postId directly
        postId: postId, // Using postId directly
        profileURL:
            userData['profileImagePath'] ?? 'assets/images/sampleProfile.png',
      ),
    );
  }

  Widget _buildPostCountIndicator() {
    String postCountText = '${filteredPostIds.length} Bookmarked ' +
        (filteredPostIds.length == 1 ? 'Post' : 'Posts');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(postCountText,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: adjustedPostCountFontSize,
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }

  void _onPostCardTap(String postId) {
    print('Post ID: $postId');
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 8) {
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  List<Color> _assignedColors() {
    return [yellow, orange, blue, babyPink, Cyan];
  }
}
