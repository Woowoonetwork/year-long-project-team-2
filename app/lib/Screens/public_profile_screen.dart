import 'package:FoodHood/Components/post_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profileAppBar.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class PublicProfileScreen extends StatefulWidget {
  final String? userId;

  PublicProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  String? firstName;
  String? lastName;
  String? aboutMe;
  String imageUrl = "";
  bool isLoading = true;
  List<Map<String, dynamic>> recentPosts = [];
  int segmentedControlGroupValue = 0;
  final Map<int, Widget> segmentedControlChildren = const {
    0: Text(
      "Recent Posts",
      style: TextStyle(
        fontSize: 14,
        letterSpacing: -0.6,
        fontWeight: FontWeight.w500,
      ),
    ),
    1: Text("Reviews",
        style: TextStyle(
          fontSize: 14,
          letterSpacing: -0.6,
          fontWeight: FontWeight.w500,
        )),
  };
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
    if (mounted) {
      setState(() {
        recentPosts = snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'postId': doc.id,
                })
            .toList();
        isLoading = false;
      });
    }
  }

  void determineUserId() {
    effectiveUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUserId != null) {
      setUpStreamListener(effectiveUserId!);
      fetchRecentPosts();
    } else {
      setState(() => isLoading = false);
    }
  }

  void setUpStreamListener(String userId) {
    firestore.collection('user').doc(userId).snapshots().listen((snapshot) {
      if (mounted && snapshot.exists) {
        updateProfileData(snapshot.data()!);
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  void updateProfileData(Map<String, dynamic> documentData) {
    if (mounted) {
      setState(() {
        firstName = documentData['firstName'] as String? ?? '';
        lastName = documentData['lastName'] as String?;
        aboutMe = documentData['aboutMe'] as String? ?? '';
        imageUrl = documentData['profileImagePath'] as String? ?? '';
        if (aboutMe == null || aboutMe!.trim().isEmpty) {
          aboutMe = "No description available";
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    switch (segmentedControlGroupValue) {
      case 0:
        contentWidget = RecentPostsTab(recentPosts: recentPosts);
        break;
      case 1:
        contentWidget = ReviewsTab(userId: effectiveUserId, imageUrl: imageUrl);
        break;
      default:
        contentWidget = SizedBox.shrink(); // Fallback to an empty widget
    }

    return Scaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      body: CustomScrollView(
        slivers: <Widget>[
          ProfileAppBar(
              isCurrentUser: false,
              isBlocked: false,
              imageUrl: imageUrl,
              userId: effectiveUserId,
              firstName: firstName,
              lastName: lastName,
              onBlockPressed: () {}),
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: true,
              top: false,
              child: Column(
                children: <Widget>[
                  AboutSection(firstName: firstName, aboutMe: aboutMe),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    width: MediaQuery.of(context).size.width,
                    child: CupertinoSlidingSegmentedControl<int>(
                      children: segmentedControlChildren,
                      onValueChanged: (value) {
                        setState(() {
                          segmentedControlGroupValue = value!;
                        });
                      },
                      groupValue: segmentedControlGroupValue,
                    ),
                  ),
                  contentWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final String? firstName;
  final String? aboutMe;

  const AboutSection({Key? key, this.firstName, this.aboutMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text('About ${firstName ?? "User"}',
              style: TextStyle(
                color:
                    CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.70,
              )),
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
                blurRadius: 10,
                offset: Offset(0, 0),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('${aboutMe ?? "No description Available"}',
                style: TextStyle(
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.40,
                )),
          ),
        ),
      ],
    );
  }
}

class RecentPostsTab extends StatelessWidget {
  final List<Map<String, dynamic>> recentPosts;

  const RecentPostsTab({Key? key, required this.recentPosts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return recentPosts.isEmpty
        ? Center(child: Text("No posts available"))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentPosts.length,
            itemBuilder: (context, index) {
              final post = recentPosts[index];
              // Assuming these are the keys in your post map.
              final List<Map<String, String>> imagesWithAltText =
                  (post['imagesWithAltText'] as List<dynamic>?)
                          ?.map((image) => {
                                'url': image['url'] as String,
                                'alt_text': image['alt_text'] as String,
                              })
                          .toList() ??
                      [];

              final String title = post['title'] ?? 'No Title';
              final List<String> tags = post['tags']?.cast<String>() ?? [];
              final List<Color> tagColors = tags
                  .map((_) => Colors.transparent)
                  .toList(); // Placeholder for actual colors
              final String firstname = post['firstname'] ?? 'Firstname';
              final String lastname = post['lastname'] ?? 'Lastname';
              final String timeAgo = post['timeAgo'] ?? 'Some time ago';
              final String postId = post['postId'] ?? '';
              final String profileURL = post['profileURL'] ?? '';

              return PostCard(
                imagesWithAltText: imagesWithAltText,
                title: title,
                tags: tags,
                tagColors: tagColors,
                firstname: firstname,
                lastname: lastname,
                timeAgo: timeAgo,
                onTap: (postId) => print(postId),
                postId: postId,
                showShadow: true,
                profileURL: profileURL,
              );
            },
          );
  }
}

class ReviewsTab extends StatelessWidget {
  final String? userId;
  final String imageUrl;

  const ReviewsTab({Key? key, this.userId, required this.imageUrl})
      : super(key: key);

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
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveUserId =
        userId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    return FutureBuilder<List<String>>(
      future: fetchComments(effectiveUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No reviews available"));
        } else {
          List<String> comments = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                  leading:
                      CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
                  title: Text(comment));
            },
          );
        }
      },
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String review;
  final String avatarUrl;

  const ReviewItem({Key? key, required this.review, required this.avatarUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(avatarUrl)),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(review,
                  style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label.resolveFrom(context))),
            ),
          ),
        ],
      ),
    );
  }
}
