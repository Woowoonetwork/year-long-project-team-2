import 'package:FoodHood/Components/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profile_appbar.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  ProfileScreen({Key? key, this.userId}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? firstName;
  String? lastName;
  String? aboutMe;
  String imageUrl = "";
  bool isLoading = true;
  List<Map<String, dynamic>> recentPosts = [];
  int segmentedControlGroupValue = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? effectiveUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    determineUserId().then((_) {
      if (effectiveUserId != null) {
        setUpStreamListener(effectiveUserId!);
        fetchRecentPosts();
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    });
  }

  Future<void> determineUserId() async {
    effectiveUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
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
        contentWidget = Container();
    }

    Map<int, Widget> segmentedControlChildren = {
      0: Text(
        "Recent Posts",
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 14,
          letterSpacing: -0.6,
          fontWeight: FontWeight.w500,
        ),
      ),
      1: Text("Reviews",
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 14,
            letterSpacing: -0.6,
            fontWeight: FontWeight.w500,
          )),
    };

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
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final String? firstName;
  final String? aboutMe;

  AboutSection({Key? key, this.firstName, this.aboutMe}) : super(key: key);

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
          margin: EdgeInsets.symmetric(horizontal: 20.0),
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
        ? const Center(child: Text("No posts available"))
        : ListView.separated(
            separatorBuilder: (context, index) =>
                const SizedBox(height: 20), // Consistent spacing between items
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                vertical: 20), // Padding at the start and end of the list
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPosts.length,
            itemBuilder: (context, index) {
              final post = recentPosts[index];
              final imagesWithAltText = post['images'] as List<dynamic>? ?? [];
              final firstImage =
                  imagesWithAltText.isNotEmpty ? imagesWithAltText[0] : null;

              final String title = post['title'] ?? 'No Title';
              final List<String> tags = post['tags']?.cast<String>() ?? [];
              final String firstName = post['firstName'] ?? 'Firstname';
              final String lastName = post['lastName'] ?? 'Lastname';
              final String timeAgo = post['timeAgo'] ?? 'Some time ago';
              final String postId = post['postId'] ?? '';
              final String profileURL = post['profileURL'] ?? '';

              return PostCard(
                imagesWithAltText: firstImage != null
                    ? [
                        {
                          'url': firstImage['url'],
                          'alt_text': firstImage['alt_text'] ?? ''
                        }
                      ]
                    : [],
                title: title,
                tags: tags,
                tagColors: tags.map((_) => Colors.transparent).toList(),
                firstName: firstName,
                lastName: lastName,
                timeAgo: timeAgo,
                onTap: (postId) => print('Tapped on post: $postId'),
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

  ReviewsTab({Key? key, this.userId, required this.imageUrl}) : super(key: key);

  Future<List<String>> fetchComments(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      return List<String>.from(userDoc['comments'] ?? []);
    } catch (e) {
      print(
          e); // Ideally, use a logging framework or handle the error appropriately.
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
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading reviews'));
        } else if (snapshot.data!.isEmpty) {
          return const Center(child: Text("No reviews available"));
        } else {
          return ListView.separated(
            separatorBuilder: (_, __) =>
                const SizedBox(height: 10), // Spacing between items
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                vertical: 20), // Padding at the start and end of the list
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final comment = snapshot.data![index];
              return ReviewItem(review: comment);
            },
          );
        }
      },
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String review;
  ReviewItem({Key? key, required this.review}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 10,
                offset: Offset(0, 0),
              )
            ],
            color:
                CupertinoColors.tertiarySystemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12)),
        child: Text(review,
            style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.label.resolveFrom(context))),
      ),
    );
  }
}
