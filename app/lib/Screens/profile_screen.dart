import 'package:FoodHood/Components/profile_post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profile_appbar.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:FoodHood/Screens/post_edit_screen.dart';

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
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    determineUserId().then((_) {
      if (userId != null) {
        setUpStreamListener(userId!);
        fetchRecentPosts();
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    });
  }

  Future<void> determineUserId() async {
    userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
  }

  void fetchRecentPosts() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: userId)
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
    void _removePost(String postId) async {
      try {
        await firestore.collection('post_details').doc(postId).delete();
        setState(() {
          recentPosts.removeWhere((post) => post['postId'] == postId);
        });
      } catch (e) {
        print("Error removing post: $e");
        // Show an error message if needed
      }
    }

    switch (segmentedControlGroupValue) {
      case 0:
        contentWidget = RecentPostsTab(
          recentPosts: recentPosts,
          userId: userId,
          onRemove: _removePost, // Add this line
          onEdit: (postId) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EditPostScreen(postId: postId)
              ),
            );
          },
        );
        break;
      case 1:
        contentWidget = ReviewsTab(userId: userId, imageUrl: imageUrl);
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
              userId: userId,
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
                SafeArea(top: false, child: contentWidget),
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
  final String? userId;
  final Function(String) onRemove;
  final Function(String) onEdit;

  RecentPostsTab({Key? key, required this.recentPosts, this.userId, required this.onRemove, required this.onEdit}) : super(key: key);

  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      return userDoc.exists
          ? userDoc.data() as Map<String, dynamic>
          : {'firstName': 'Unknown', 'lastName': '', 'profileImagePath': ''};
    } catch (e) {
      print('Error fetching user details: $e');
      return {'firstName': 'Error', 'lastName': '', 'profileImagePath': ''};
    }
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 7) {
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} day${duration.inDays > 1 ? "s" : ""} ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? "s" : ""} ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return recentPosts.isEmpty
        ? const Center(child: Text("No posts available"))
        : ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 20),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPosts.length,
            itemBuilder: (context, index) {
              final post = recentPosts[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: fetchUserDetails(post['user_id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                        width: 300, child: CupertinoActivityIndicator());
                  }
                  final imagesWithAltText =
                      post['images'] as List<dynamic>? ?? [];
                  final firstImage = imagesWithAltText.isNotEmpty
                      ? imagesWithAltText[0]
                      : null;
                  final createdAt =
                      (post['post_timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();
                  List<String> tags = (post['categories'] as String?)
                          ?.split(',')
                          .map((tag) => tag.trim())
                          .toList() ??
                      [];

                  return ProfilePostCard(
                    imagesWithAltText: firstImage != null
                        ? [
                            {
                              'url': firstImage['url'],
                              'alt_text': firstImage['alt_text'] ?? ''
                            }
                          ]
                        : [],
                    title: post['title']!,
                    tags: tags,
                    orderInfo: 'Posted on ${timeAgoSinceDate(createdAt)}',
                    onTap: (postId) {
                      print('Tapped on post: $postId');
                    },
                    postId: post['postId']!,
                    onRemove: () => onRemove(post['postId']!),
                    onEdit: () => onEdit(post['postId']!),
                    isCurrentUser: userId == FirebaseAuth.instance.currentUser?.uid,

                  );
                },
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
