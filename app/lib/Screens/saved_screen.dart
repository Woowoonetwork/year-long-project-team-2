import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<String> savedPostIds = [];
  bool isLoading = true;
  StreamSubscription? _savedPostsSubscription;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(),
          if (isLoading) // If it's loading, show the loading indicator
            _buildLoadingSliver()
          else if (savedPostIds
              .isEmpty) // If there are no saved posts, show the empty message
            _buildNoSavedPostsMessage()
          else // If there are saved posts, show the list
            _buildSavedPostsList(savedPostIds),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSavedPosts();
    _listenForSavedPosts();
  }

  Future<void> _fetchSavedPosts() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    var document =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (document.exists && document.data()!.containsKey('saved_posts')) {
      savedPostIds = List<String>.from(document.data()!['saved_posts']);
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
      largeTitle: Text('Saved'),
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
          // Check if the current index is the last item in the list
          if (index < savedPostIds.length) {
            return _buildPostItem(context, savedPostIds[index]);
          } else if (index == savedPostIds.length && savedPostIds.isNotEmpty) {
            // If it's the last item and the list is not empty, display the post count
            return _buildPostCountIndicator(savedPostIds.length);
          }
          return null; // Return null for indices beyond the data range
        },
        childCount: savedPostIds.isEmpty
            ? 0
            : savedPostIds.length + 1, // Add +1 for the post count indicator
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, String postId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('post_details')
          .doc(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SizedBox.shrink();
        }

        var data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return SizedBox.shrink();
        }
        // Correctly cast the data now that we've checked it
        Map<String, dynamic> postData = data;

        // Fetch the user data for the post
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(postData['user_id'])
              .get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return SizedBox
                  .shrink(); // No user data exists, return an empty widget
            }

            var userData = userSnapshot.data!.data();
            if (userData == null || userData is! Map<String, dynamic>) {
              return SizedBox
                  .shrink(); // User data is null or not the expected format, return an empty widget
            }

            // Now we can safely use postData and userData, knowing they're not null and are properly formatted
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
            Icon(FeatherIcons.inbox,
                size: 80,
                color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            SizedBox(height: 20),
            Text(
              'No Saved Posts',
              style: TextStyle(
                  fontSize: 24,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Posts you save will appear here.',
              style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel),
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

  Widget _buildPostCountIndicator(int postCount) {
    String postCountText =
        '$postCount Saved ' + (postCount > 1 ? 'Posts' : 'Post');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(postCountText,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 14.0,
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
    return [
      CupertinoColors.systemRed,
      CupertinoColors.systemOrange,
      CupertinoColors.systemYellow,
      CupertinoColors.systemGreen,
      CupertinoColors.systemBlue,
      CupertinoColors.systemIndigo,
      CupertinoColors.systemPurple,
    ];
  }
}
