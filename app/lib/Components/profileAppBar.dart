import 'package:FoodHood/Components/appBarVisibilityController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:palette_generator/palette_generator.dart';
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

class ProfileAppBar extends StatefulWidget {
  final String postId;
  final VoidCallback onBlockPressed;
  final bool isBlocked;
  final bool
      isCurrentUser; // New parameter to determine if the profile belongs to the current user
  final String imageUrl;
  final String? userId;
  final String? firstName;
  final String? lastName;

  const ProfileAppBar({
    Key? key,
    required this.postId,
    required this.onBlockPressed,
    required this.isBlocked,
    required this.isCurrentUser, // Initialize in the constructor
    required this.imageUrl,
    this.firstName,
    this.lastName,
    this.userId,
  }) : super(key: key);

  @override
  _ProfileAppBarState createState() => _ProfileAppBarState();
}

class _ProfileAppBarState extends State<ProfileAppBar> {
  Color? _backgroundColor;
  String? _firstName; // Variable to store the first name
  String? _lastName;
  String? _city;
  String? _province;
  double? _rating;
  String? _imageUrl;
  int _postsSold = 0; // Holds the background color extracted from the image

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchUserDetails(widget.userId!).then((_) {
        // Ensure palette is updated after user details are fetched
        _updatePaletteGenerator();
      });
      _fetchPostsSoldCount(widget.userId!);
    } else {
      // If there's no userId, update the palette generator with the default or passed imageUrl
      _updatePaletteGenerator();
    }
  }

  Future<void> _blockUser(String userIdToBlock) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return; // Ensure there is a logged-in user

    final userRef =
        FirebaseFirestore.instance.collection('user').doc(currentUser.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          List<dynamic> blockedUsers = userDoc.data()?['blocked'] ?? [];
          // Check if the user is already blocked to prevent duplicates
          if (!blockedUsers.contains(userIdToBlock)) {
            blockedUsers.add(userIdToBlock);
            transaction.update(userRef, {'blocked': blockedUsers});
          }
        }
      });

      print("User successfully blocked.");
    } catch (e) {
      print("Failed to block user: $e");
    }
  }

  Future<void> _fetchUserDetails(String userId) async {
    final userData =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (userData.exists) {
      setState(() {
        _firstName = userData.data()?['firstName'] as String?;
        _lastName = userData.data()?['lastName'] as String?;
        _city = userData.data()?['city'] as String?;
        _province = userData.data()?['province'] as String?;
        _rating = userData.data()?['avgRating']?.toDouble();
        _imageUrl = userData.data()?['profileImagePath'] as String?;
      });
    }
  }

  Future<void> _fetchPostsSoldCount(String userId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: userId)
        .where('post_status', isEqualTo: "completed")
        .get();

    if (mounted) {
      setState(() {
        _postsSold = querySnapshot
            .docs.length; // Count of documents with "completed" status
      });
    }
  }

  Future<void> _updatePaletteGenerator() async {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      _imageUrl =
          'assets/images/sampleProfile.png'; // Fallback image URL or asset
    }

    ImageProvider imageProvider;
    if (_imageUrl!.startsWith('http')) {
      imageProvider = CachedNetworkImageProvider(_imageUrl!);
    } else {
      imageProvider = AssetImage(_imageUrl!);
    }

    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: Size(200, 100), // Adjust the size according to your needs
    );

    if (mounted) {
      setState(() {
        _backgroundColor =
            generator.vibrantColor?.color ?? CupertinoColors.systemGrey;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      expandedHeight: 250,
      elevation: 0,
      stretch: true,
      pinned: true,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.fadeTitle],
        background: _buildGradientBackground(),
        expandedTitleScale: 1.0,
        title: VisibilityController(
          expandedChild: _buildUserInfoRow(),
          collapsedChild: _buildCollapsedUserInfo(),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20.0, bottom: 16.0),
      ),
      leading: _buildLeading(context),
      actions: [
        if (!widget.isCurrentUser) buildBlockButton(context),
      ],
    );
  }

  Widget _buildCollapsedUserInfo() {
    return Text(
      '${_firstName ?? "Loading..."} ${_lastName ?? ""}',
      style: TextStyle(
          fontSize: 20,
          letterSpacing: -0.6,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.label.resolveFrom(context)),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return CupertinoButton(
      child: Icon(FeatherIcons.chevronLeft,
          size: 24, color: CupertinoColors.label.resolveFrom(context)),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildGradientBackground() {
    // Fallback to a default color if _backgroundColor is null
    final backgroundColor = _backgroundColor ?? CupertinoColors.systemOrange;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor, // Dynamically extracted color
            CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
          ],
        ),
      ),
    );
  }

  Widget buildBlockButton(BuildContext context) {
    return CupertinoButton(
      child: Text('Block',
          style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
      onPressed: () => _showBlockMenu(context),
    );
  }

  Widget _buildUserInfoRow() {
    String location = 'unknown';
    String displayName = 'User'; // Default display name
    if (_firstName != null && _lastName != null) {
      displayName = '$_firstName $_lastName';
    }
    if (_city != null && _province != null) {
      location = '$_city, $_province';
    }
    ImageProvider<Object> _getAvatarImageProvider() {
      // Check if imageUrl is not null and not empty
      if (widget.imageUrl.isNotEmpty) {
        return CachedNetworkImageProvider(widget.imageUrl);
      } else {
        // Fallback to a local asset if imageUrl is not available
        return AssetImage('assets/images/sampleProfile.png');
      }
    }

    List<Widget> stars = [];
    Color starColor = _backgroundColor ?? CupertinoColors.systemOrange;
    // Generate star icons based on rating
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        // Always use CupertinoIcons.star for unfilled stars to ensure they appear completely unfilled
        _rating != null && i < _rating!
            ? CupertinoIcons.star_fill
            : CupertinoIcons.star,
        color: starColor, // Use the extracted photo icon color for all stars
        size: 14,
      ));
    }

    String ratingText = _rating != null
        ? '  ${_rating!.toStringAsFixed(1)} Ratings, '
        : '  No rating available, ';
    String postsSoldText = '$_postsSold items sold';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: _getAvatarImageProvider(),
              radius: 34,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                        fontSize: 24,
                        letterSpacing: -1.0,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label.resolveFrom(context)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    location,
                    style: TextStyle(
                        fontSize: 13,
                        letterSpacing: -0.3,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context)),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: stars.followedBy([
                      Text(
                        ratingText,
                        style: TextStyle(
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: -0.4),
                      ),
                      Text(
                        postsSoldText, // Add the posts sold text here
                        style: TextStyle(
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: -0.4),
                      ),
                    ]).toList(),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showBlockMenu(BuildContext context) {
    String displayName = 'User'; // Default display name
    if (_firstName != null && _lastName != null) {
      displayName = '$_firstName $_lastName';
    }
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Block $displayName',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 18,
            letterSpacing: -0.60,
          ),
        ),
        message: Text(
          'You will no longer see any posts from $displayName.',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 14,
            letterSpacing: -0.40,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              'Confirm',
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.80,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close the action sheet
              if (widget.userId != null) {
                try {
                  await _blockUser(widget.userId!);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSuccessDialog(context);
                  });
                } catch (error) {
                  print("Error blocking user: $error");
                }
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog is not dismissible by tapping outside
      builder: (BuildContext context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          content: Text('You have successfully blocked this user'),
        );
      },
    );
  }
}
