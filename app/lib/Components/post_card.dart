import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Screens/posting_detail.dart'; // Update this import
import 'package:FoodHood/Components/colors.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import

class PostCard extends StatelessWidget {
  final String imageLocation;
  final String firstname;
  final String lastname;
  final String title;
  final List<String> tags;
  final List<Color> tagColors;
  final String timeAgo;
  final Function(String) onTap; // New callback parameter
  final String postId;
  final String profileURL; // New parameter to store the profile image URL
  final bool showTags; // New parameter to indicate whether to show tags or not

  PostCard({
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
        child: Center(
          child: Container(
            decoration: _buildBoxDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
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
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Check if imageLocation is a valid URL, if not, use default image
    bool isImageLocationValid =
        imageLocation.isNotEmpty; // Add your own validation logic if needed

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      child: isImageLocationValid
          ? CachedNetworkImage(
              imageUrl: imageLocation,
              width: MediaQuery.of(context).size.width,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  CupertinoActivityIndicator(), // Placeholder widget
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/sampleFoodPic.png', // Fallback image on error
                width: MediaQuery.of(context).size.width,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/sampleFoodPic.png', // Default image path
              width: MediaQuery.of(context).size.width,
              height: 100,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _defaultImage(BuildContext context) {
    return Image.asset(
      'assets/images/sampleFoodPic.png', // Replace with your default image path
      width: MediaQuery.of(context).size.width,
      height: 100,
      fit: BoxFit.cover,
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
    String effectiveAvatarUrl = avatarUrl.isEmpty
        ? 'assets/images/sampleProfile.png' // Default image
        : avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // CircleAvatar(
          //   backgroundImage: 
          //   //use
          //   radius: 9, // Adjust the radius to fit your design
          // ),

                      //use cached network image 
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: effectiveAvatarUrl,
              width: 18,
              height: 18,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  CupertinoActivityIndicator(), // Placeholder widget
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/sampleProfile.png', // Fallback image on error
                width: 18,
                height: 18,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Posted by $firstname $lastname $timeAgo',
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  
}
