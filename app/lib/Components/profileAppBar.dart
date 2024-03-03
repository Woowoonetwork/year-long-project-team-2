import 'package:FoodHood/Components/appBarVisibilityController.dart';
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

  const ProfileAppBar({
    Key? key,
    required this.postId,
    required this.onBlockPressed,
    required this.isBlocked,
    required this.isCurrentUser, // Initialize in the constructor
    required this.imageUrl,
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
  String? _province; // Holds the background color extracted from the image

  @override
  void initState() {
    super.initState();
    _updatePaletteGenerator();
    if (widget.userId != null) {
      _fetchUserDetails(widget.userId!);
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
      });
    }
  }

  Future<void> _updatePaletteGenerator() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      AssetImage('assets/images/sampleProfile.png'), // Use your image asset
      size: Size(200, 100), // Size of the area from which to pick colors
    );
    if (mounted) {
      setState(() {
        // Use vibrant color as background, or fallback to a default color
        _backgroundColor =
            generator.vibrantColor?.color ?? CupertinoColors.systemOrange;
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
      'Harry Styles',
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  Image.asset('assets/images/sampleProfile.png').image,
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
                    children: [
                      Icon(CupertinoIcons.star_fill,
                          color: _backgroundColor, size: 14),
                      Icon(CupertinoIcons.star_fill,
                          color: _backgroundColor, size: 14),
                      Icon(CupertinoIcons.star_fill,
                          color: _backgroundColor, size: 14),
                      Icon(CupertinoIcons.star_fill,
                          color: _backgroundColor,
                          size: 14), // Use system colors for consistency
                      Icon(CupertinoIcons.star_fill,
                          color: _backgroundColor, size: 14),
                      Text('  5.0 Ratings',
                          style: TextStyle(
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              letterSpacing: -0.4)),
                      Text('  10 items sold',
                          style: TextStyle(
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              letterSpacing: -0.4)),
                    ],
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
        message: Text('You will no longer see any posts from Harry Styles.',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 14,
              letterSpacing: -0.40,
              fontWeight: FontWeight.w500,
            )),
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
            onPressed: () {},
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
}
