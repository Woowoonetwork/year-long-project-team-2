import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'dart:ui';
import 'package:FoodHood/Components/colors.dart';

// ProfileAppBar
class ProfileAppBar extends StatefulWidget {
  final String postId;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;
  final String imageUrl;

  const ProfileAppBar({
    Key? key,
    required this.postId,
    required this.onFavoritePressed,
    required this.isFavorite,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ProfileAppBarState createState() => _ProfileAppBarState();
}

class _ProfileAppBarState extends State<ProfileAppBar> {
  bool isFavorite = false;
  String? imageUrl = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      expandedHeight: 350, // Increased height to accommodate the user info row
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Column(
          children: [
            _buildGradientBackground(),
            _buildUserInfoRow(), // Add this method to build the user information row
          ],
        ),
      ),
      leading: _buildLeading(context),
      actions: [buildBlockButton(context)],
    );
  }

  Widget _buildLeading(BuildContext context) {
    return CupertinoButton(
      child: Icon(FeatherIcons.x, size: 24, color: CupertinoColors.label.resolveFrom(context)),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: 300, // Specify the height for the gradient background
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.systemOrange,
            CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
          ],
        ),
      ),
    );
  }

  Widget buildBlockButton(BuildContext context) {
    return CupertinoButton(
      child: Text('Block', style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
      onPressed: widget.onFavoritePressed,
    );
  }

  Widget _buildUserInfoRow() {
    // Method to create the user information row
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200, // Placeholder for profile picture
            radius: 30,
            child: Text('HS'), // Placeholder for user initials
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harry Styles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kelowna, British Columbia',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(' 5.0 Ratings', style: TextStyle(fontSize: 14)),
                    Text(' | 10 items sold', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
