import 'package:FoodHood/Components/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profileAppBar.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:feather_icons/feather_icons.dart';
import '../components.dart';
// import gesture
import 'package:flutter/services.dart';

class PublicProfileScreen extends StatefulWidget {
  final String? userId; // Make userId optional

  PublicProfileScreen({Key? key, this.userId})
      : super(key: key); // Adjust constructor

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final String postId = "examplePostId";
  String? firstName;
  String? lastName;
  String? aboutMe;
  final bool isFavorite = false;
  final String imageUrl = "";
  bool isLoading = true;

  bool isLoadingPosts = true;
  List<Map<String, dynamic>> recentPosts = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? effectiveUserId;

  @override
  void initState() {
    super.initState();
    determineUserId();
  }

  void fetchRecentPosts() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: effectiveUserId)
        .get();
    print(effectiveUserId);

    if (mounted) {
      setState(() {
        recentPosts = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  void determineUserId() {
    effectiveUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUserId != null) {
      setUpStreamListener(effectiveUserId!);
      fetchRecentPosts(); // Fetch recent posts
    } else {
      setState(() => isLoading = false);
    }
  }

  void setUpStreamListener(String userId) {
    firestore.collection('user').doc(userId).snapshots().listen(
      (snapshot) {
        if (mounted && snapshot.exists) {
          updateProfileData(snapshot.data()!);
        } else {
          if (mounted) setState(() => isLoading = false);
        }
      },
      onError: (e) {
        if (mounted) {
          print('Error listening to user data changes: $e');
          setState(() => isLoading = false);
        }
      },
    );
  }

  void updateProfileData(Map<String, dynamic> documentData) {
    if (mounted) {
      setState(() {
        firstName = documentData['firstName'] as String? ?? '';
        lastName = documentData['lastName'] as String?;
        aboutMe = documentData['aboutMe'] as String? ?? '';
        if (aboutMe == null || aboutMe!.trim().isEmpty) {
          aboutMe = "No description available"; // Default message
        }
        // Update other user details as necessary
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      body: CustomScrollView(
        slivers: <Widget>[
          ProfileAppBar(
            postId: postId,
            onBlockPressed: () {
              // Block user here
            },
            isCurrentUser: false,
            isBlocked: isFavorite,
            imageUrl: imageUrl,
            userId: effectiveUserId,
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: true,
              top: false,
              child: Column(
                children: <Widget>[
                  AboutSection(firstName: firstName, aboutMe: aboutMe),
                  RecentPostSection(
                    recentPosts: recentPosts,
                  ),
                  ReviewSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ReviewSection
class ReviewSection extends StatelessWidget {
  final String? userId;

  ReviewSection({this.userId});

  Future<List<String>> fetchComments(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('comments')) {
          final List<dynamic> comments = userData['comments'];
          return comments.cast<String>();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveUserId =
        userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
          child: Text(
            'Reviews',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FutureBuilder<List<String>>(
          future: fetchComments(effectiveUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  "No reviews available",
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 16,
                  ),
                ),
              );
            }

            List<String> comments = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: comments
                    .map((comment) => ReviewItem(review: comment))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  final String? firstName;
  final String? aboutMe;

  const AboutSection({Key? key, this.firstName, this.aboutMe})
      : super(key: key); // Include aboutMe in the constructor
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'About ${firstName ?? "User"}',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.70,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                CupertinoColors.tertiarySystemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '${aboutMe ?? "No description Available"}',
              style: TextStyle(
                color:
                    CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String review;

  const ReviewItem({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/sampleProfile.png'),
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentPostSection extends StatelessWidget {
  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    try {
      // Attempt to fetch the user document from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();

      if (userDoc.exists) {
        // If the document exists, return the user data
        return userDoc.data() as Map<String, dynamic>;
      } else {
        // If the user document does not exist, return an empty map or default values
        return {'firstName': 'Unknown', 'lastName': '', 'profileImagePath': ''};
      }
    } catch (e) {
      // In case of any errors, log the error and return default values
      print('Error fetching user details: $e');
      return {'firstName': 'Error', 'lastName': '', 'profileImagePath': ''};
    }
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 7)
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    if (duration.inDays >= 1)
      return '${duration.inDays} day${duration.inDays > 1 ? "s" : ""} ago';
    if (duration.inHours >= 1)
      return '${duration.inHours} hour${duration.inHours > 1 ? "s" : ""} ago';
    if (duration.inMinutes >= 1)
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""} ago';
    return 'just now';
  }

  Color _getRandomColor() {
    var colors = [yellow, orange, blue, babyPink, Cyan];
    return colors[math.Random().nextInt(colors.length)];
  }

  final List<Map<String, dynamic>> recentPosts;

  RecentPostSection({Key? key, required this.recentPosts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
          child: Text(
            'Recent Posts',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (recentPosts.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "No posts are available",
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 16,
              ),
            ),
          )
        else
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 5, right: 20),
              itemCount: recentPosts.length,
              itemBuilder: (context, index) {
                final post = recentPosts[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchUserDetails(
                      post['user_id']), // Implement this method
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                          width: 300, child: CupertinoActivityIndicator());
                    }
                    final user = snapshot.data!;
                    final imagesWithAltText =
                        post['images'] as List<dynamic>? ?? [];
                    final firstImage = imagesWithAltText.isNotEmpty
                        ? imagesWithAltText[0]
                        : null;

                    var createdAt =
                        (post['post_timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    List<String> tags = (post['categories'] as String?)
                            ?.split(',')
                            .map((tag) => tag.trim())
                            .toList() ??
                        [];
                    Map<String, Color> tagColors = {};
                    List<Color> assignedColors = tags
                        .map((tag) =>
                            tagColors.putIfAbsent(tag, () => _getRandomColor()))
                        .toList();

                    return PostCard(
                      imagesWithAltText: firstImage != null
                          ? [
                              {
                                'url': firstImage['url'],
                                'alt_text': firstImage['alt_text'] ?? ''
                              }
                            ]
                          : [],
                      title: post['title'],
                      tags: tags,

                      tagColors: assignedColors, // Simplified for demonstration
                      firstname: user['firstName'],
                      lastname: user['lastName'],

                      timeAgo: timeAgoSinceDate(
                          createdAt), // Implement a method to convert timestamp to "time ago" format
                      onTap: (postId) {},
                      postId: '7cc0e4f5-076d-4802-b4bf-07ee1f017d5f',
                      profileURL: user['profileImagePath'] ?? '',

                      showTags: true,
                      imageHeight: 100.0,
                      showShadow: true,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
