import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/firestore_service.dart';

import 'package:intl/intl.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(),
          _buildSavedPostsStream(),
        ],
      ),
    );
  }

  CupertinoSliverNavigationBar _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: groupedBackgroundColor,
      largeTitle: Text('Saved'),
      border: Border(bottom: BorderSide.none),
      stretch: true,
    );
  }

  

  StreamBuilder<DocumentSnapshot> _buildSavedPostsStream() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('user').doc(userId).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SliverFillRemaining(
          child: Center(child: CupertinoActivityIndicator()),
        );
      }

      if (!snapshot.hasData || snapshot.data!['saved_posts'] == null || (snapshot.data!['saved_posts'] as List).isEmpty) {
        // No posts available
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FeatherIcons.box, // Replace FeatherIcons.box with the appropriate icon if it's not available
                  size: 40,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(height: 20),
                Text(
                  'No saved posts',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Proceed with existing logic if posts are available
      List<dynamic> savedPostIds = snapshot.data!['saved_posts'];
      return _buildSavedPostsList(savedPostIds);
    },
  );
}

 SliverList _buildSavedPostsList(List<dynamic> savedPostIds) {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (index < savedPostIds.length) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('post_details')
                .doc(savedPostIds[index])
                .get(),
            builder: (context, postSnapshot) {
              if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                return SizedBox.shrink();
              }

              var postData = postSnapshot.data!.data() as Map<String, dynamic>;
              String userId = postData['user_id'] ?? 'Unknown';

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SizedBox.shrink(); // Or some loading indicator
                  }

                  var userData = userSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Adjusted vertical padding
                    child: PostCard(
                      imageLocation: postData['image_url'] ??
                          'assets/images/sampleFoodPic.png',
                      title: postData['title'] ?? 'No Title',
                      tags: (postData['categories'] as String)
                          .split(',')
                          .map((tag) => tag.trim())
                          .toList(),
                      firstname: userData['firstName'] ??
                          'Unknown', // Corrected to userData
                      lastname: userData['lastName'] ??
                          'Unknown', // Corrected to userData
                      timeAgo: timeAgoSinceDate(
                          (postData['post_timestamp'] as Timestamp).toDate()),
                      tagColors: _assignedColors(),
                      onTap: (postId) => _onPostCardTap(
                          postId), // Make sure this callback is correctly implemented
                      postId: savedPostIds[index],
                    ),
                  );
                },
              );
            },
          );
        } else {
          // This will execute when index is equal to the length of savedPostIds
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('${savedPostIds.length} Saved Posts',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          );
        }
      },
      childCount: savedPostIds.length + (savedPostIds.isNotEmpty ? 1 : 0),
    ),
  );
}


  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .get();

  if (!userSnapshot.exists) {
    return {'firstName': 'Unknown', 'lastName': 'Unknown'};
  }

  return userSnapshot.data() as Map<String, dynamic>;
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
