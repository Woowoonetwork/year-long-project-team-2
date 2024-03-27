import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/message_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DoneeRatingPage extends StatefulWidget {
  final String postId;
  final String receiverID;
  const DoneeRatingPage(
      {super.key, required this.postId, required this.receiverID});
  @override
  _DoneeRatingPageState createState() => _DoneeRatingPageState();
}

class _DoneeRatingPageState extends State<DoneeRatingPage> {
  String? reservedByName;
  String? image;
  String? recervedByID;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  bool get _isPublishButtonEnabled {
    return _rating > 0 && _commentController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          border: null,
          backgroundColor: backgroundColor,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(FeatherIcons.x,
                size: 22, color: CupertinoColors.label.resolveFrom(context)),
          ),
          trailing: GestureDetector(
            onTap: () {
              MessageScreen(
                receiverID: recervedByID!,
              );
            },
            child: Text(
              'Message ${reservedByName!}',
              style: TextStyle(color: accentColor.resolveFrom(context)),
            ),
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 16),
                      child: Text(
                        "How was your experience with ${reservedByName!}?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 32,
                          letterSpacing: -1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(image!)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            _rating > index
                                ? Ionicons.star
                                : Ionicons.star_outline,
                            color: accentColor.resolveFrom(context),
                          ),
                          iconSize: 40,
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoTextField(
                          controller: _commentController,
                          onChanged: (_) => setState(() {}),
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          textCapitalization: TextCapitalization.sentences,
                          placeholder:
                              'Write a review for ${reservedByName!}',
                          decoration: BoxDecoration(
                            color: groupedBackgroundColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          placeholderStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.8,
                            color: CupertinoColors.placeholderText
                                .resolveFrom(context),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildButton(context, "Publish", FeatherIcons.check),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchReservedByName() async {
    final CollectionReference postDetailsCollection =
        FirebaseFirestore.instance.collection('post_details');

    final String postId = widget.postId;
    try {
      final DocumentSnapshot postSnapshot =
          await postDetailsCollection.doc(postId).get();

      if (postSnapshot.exists) {
        final reservedByUserId = postSnapshot['reserved_by'];
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(reservedByUserId)
            .get();

        if (userSnapshot.exists) {
          final userName = userSnapshot['firstName'];
          setState(() {
            reservedByName = userName;
            image = userSnapshot['profileImagePath'] as String? ?? '';
          });
        } else {
          print(
              'User document does not exist for reserved by user ID: $reservedByUserId');
        }
      } else {
        print('Post details document does not exist for ID: $postId');
      }
    } catch (error) {
      print('Error fetching reserved by user name: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReservedByName();
  }

  Widget _buildButton(BuildContext context, String text, IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(100.0),
          color: _isPublishButtonEnabled
              ? CupertinoColors.systemBackground.resolveFrom(context)
              : CupertinoColors.systemGrey4.resolveFrom(context),
          onPressed: _isPublishButtonEnabled
              ? () async {
                  await _storeCommentInDatabase();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: _isPublishButtonEnabled
                        ? CupertinoColors.label.resolveFrom(context)
                        : CupertinoColors.inactiveGray,
                    fontSize: 18,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 20,
                  color: _isPublishButtonEnabled
                      ? CupertinoColors.label.resolveFrom(context)
                      : CupertinoColors.inactiveGray,
                ),
              ],
            ),
          )),
    );
  }

  Future<void> _storeCommentInDatabase() async {
    String comment = _commentController.text;
    int starRating = _rating;

    DocumentReference postDocRef = FirebaseFirestore.instance
        .collection('post_details')
        .doc(widget.postId);

    try {
      DocumentSnapshot postDoc = await postDocRef.get();

      if (postDoc.exists && postDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
        String userId = postData['reserved_by'];

        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('user').doc(userId);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          List<dynamic> comments = List.from(userData['comments'] ?? []);
          List<dynamic> ratings = List.from(userData['ratings'] ?? []);

          comments.add(comment);
          ratings.add(starRating);

          double avgRating = 0;
          if (ratings.isNotEmpty) {
            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
            avgRating = double.parse(avgRating.toStringAsFixed(2));
          }

          await userDocRef.update({
            'comments': comments,
            'ratings': ratings,
            'avgRating': avgRating
          });
          print("Rating stored in database");
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/nav',
            (route) => false,
            arguments: {'selectedIndex': 0},
          );
        } else {
          print("User document not found for ID: $userId");
        }
      } else {
        print("Post details document not found for ID: ${widget.postId}");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }
}
