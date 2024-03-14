import 'package:FoodHood/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Screens/posting_detail.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class PostCard extends StatelessWidget {
  final List<Map<String, String>> imagesWithAltText;
  final String firstName;
  final String lastName;
  final String title;
  final List<String> tags;
  final List<Color> tagColors;
  final String timeAgo;
  final Function(String) onTap;
  final String postId;
  final String profileURL;
  final bool showTags;
  final double imageHeight;
  final bool showShadow;

  PostCard({
    Key? key,
    required this.imagesWithAltText,
    required this.title,
    required this.tags,
    required this.tagColors,
    required this.firstName,
    required this.lastName,
    required this.timeAgo,
    required this.onTap,
    required this.postId,
    required this.profileURL,
    this.showTags = true,
    this.imageHeight = 100.0,
    this.showShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.selectionClick();
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
                  SizedBox(height: 2),
                ] else ...[
                  SizedBox(height: 10),
                ],
                _buildOrderInfoSection(context, profileURL, firstName, lastName,
                    timeAgo), // Add the order info section
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Use the first image URL if available, otherwise a placeholder
    final String imageToShow = imagesWithAltText.isNotEmpty
        ? imagesWithAltText[0]['url'] ?? ''
        : 'assets/images/sampleFoodPic.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      child: CachedNetworkImage(
        imageUrl: imageToShow,
        width: MediaQuery.of(context).size.width,
        height: imageHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => CupertinoActivityIndicator(),
        errorWidget: (context, url, error) =>
            buildImageFailedPlaceHolder(context, true),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
      borderRadius: BorderRadius.circular(14),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ]
          : [], // Use shadow based on the configurable flag
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
    const double spacing = 7.0; // Spacing between tags horizontally
    int tagCount = tags.length;
    int displayedTags = tagCount > 4 ? 4 : tagCount; // Display up to 4 tags
    int truncatedTags = tagCount - displayedTags; // Calculate remaining tags

    List<Widget> tagWidgets =
        tags.take(displayedTags).toList().asMap().entries.map((entry) {
      int idx = entry.key;
      String tag = entry.value;
      return Container(
        child: _buildTag(tag, _generateTagColor(idx), context),
      );
    }).toList();

    // If there are truncated tags, add a "+X" tag
    if (truncatedTags > 0) {
      tagWidgets.add(_buildTag(
          '+$truncatedTags', _generateTagColor(displayedTags), context));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing,
              children: tagWidgets,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(color, context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.computeLuminance() > 0.5
              ? CupertinoDynamicColor.resolve(CupertinoColors.black, context)
              : CupertinoDynamicColor.resolve(CupertinoColors.white, context),
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

  ImageProvider<Object> _getAvatarImageProvider(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return AssetImage('assets/images/sampleProfile.png');
    } else {
      try {
        return CachedNetworkImageProvider(avatarUrl);
      } catch (e) {
        return AssetImage('assets/images/sampleProfile.png');
      }
    }
  }

  Widget _buildOrderInfoSection(BuildContext context, String avatarUrl,
      String firstname, String lastname, String timeAgo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          avatarUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 8,
                  backgroundImage: CachedNetworkImageProvider(avatarUrl),
                  backgroundColor: Colors.transparent,
                )
              : CircleAvatar(
                  radius: 8,
                  backgroundImage:
                      AssetImage('assets/images/sampleProfile.png'),
                ),
          SizedBox(width: 8),
          Text(
            'Posted by $firstname $lastname  $timeAgo',
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
