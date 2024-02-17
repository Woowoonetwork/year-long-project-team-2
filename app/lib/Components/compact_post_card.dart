import 'package:FoodHood/Screens/public_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Screens/posting_detail.dart'; // Update this import
import 'package:FoodHood/Components/colors.dart';

class CompactPostCard extends StatelessWidget {
  final String imageLocation;
  final String firstname;
  final String lastname;
  final String title;
  final List<String> tags;
  final List<Color> tagColors;
  final String timeAgo;
  final Function(String) onTap; // New callback parameter
  final String postId;
  final profileURL; // New parameter to store the profile image URL
  final bool showTags; // New parameter to indicate whether to show tags or not

  // Define your colors here
  final List<Color> colors = [
    Colors.lightGreenAccent, // Light Green
    Colors.lightBlueAccent, // Light Blue
    Colors.pinkAccent[100]!, // Light Pink
    Colors.yellowAccent[100]! // Light Yellow
  ];

  CompactPostCard({
    Key? key,
    required this.imageLocation,
    required this.title,
    required this.tags,
    required this.tagColors,
    required this.firstname,
    required this.lastname,
    required this.timeAgo,
    required this.onTap,
    required this.postId,
    required this.profileURL,
    this.showTags = true, // Default value to show tags
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          onTap(postId);
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => PostDetailView(postId: postId),
            ),
          );
        },
        child: Container(
          decoration: _buildBoxDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              if (showTags) ...[
                _buildTagSection(context),
              ] else ...[
                SizedBox(height: 10),
              ],
              _buildOrderInfoSection(context, profileURL),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 20,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
          fontSize: 18,
          letterSpacing: -0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagSection(BuildContext context) {
    const double horizontalSpacing = 7.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: List.generate(tags.length, (index) {
          return Row(
            children: [
              _buildTag(tags[index], _generateTagColor(index), context),
              SizedBox(width: horizontalSpacing),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(CupertinoColors.black, context),
          fontSize: 10,
          letterSpacing: -0.40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _generateTagColor(int index) {
    List<Color> availableColors = [yellow, orange, blue, babyPink, Cyan];
    return availableColors[index % availableColors.length];
  }

  Widget _buildOrderInfoSection(BuildContext context, String avatarUrl) {
    // Use a default image if avatarUrl is empty or null
    String effectiveAvatarUrl =
        avatarUrl.isEmpty ? 'assets/images/sampleProfile.png' : avatarUrl;

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => PublicProfileScreen(),
              ),
            );
          },
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  effectiveAvatarUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Posted by $firstname $lastname $timeAgo',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ));
  }
}
