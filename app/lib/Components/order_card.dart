import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/donor_screen.dart';
import 'package:FoodHood/Screens/posting_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:FoodHood/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _defaultTextFontSize = 16.0;
const double _defaultTitleFontSize = 18.0;
const double _defaultTagFontSize = 10.0;
const double _defaultOrderInfoFontSize = 12.0;
const double _defaultStatusFontSize = 13.0;
const double imageHeight = 120;

enum OrderState {
  reserved,
  confirmed,
  delivering,
  readyToPickUp,
  pending,
  notReserved
}

class OrderCard extends StatelessWidget {
  final List<Map<String, String>> imagesWithAltText;
  final String title;
  final List<String> tags;
  final String orderInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final Function(String) onTap;
  final String postId;
  final VoidCallback? onStatusPressed;
  final OrderState orderState;

  OrderCard({
    Key? key,
    required this.imagesWithAltText,
    required this.title,
    required this.tags,
    required this.orderInfo,
    required this.onTap,
    required this.postId,
    this.onEdit,
    this.onCancel,
    this.onStatusPressed,
    required this.orderState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _textScaleFactor =
        Provider.of<TextScaleProvider>(context).textScaleFactor;

    double adjustedTextFontSize = _defaultTextFontSize * _textScaleFactor;
    double adjustedTitleFontSize = _defaultTitleFontSize * _textScaleFactor;
    double adjustedTagFontSize = _defaultTagFontSize * _textScaleFactor;
    double adjustedOrderInfoFontSize =
        _defaultOrderInfoFontSize * _textScaleFactor;
    double adjustedStatusFontSize = _defaultStatusFontSize * _textScaleFactor;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onCardTap(context, postId),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemBackground, context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildImageSection(context, imagesWithAltText),
                  _buildStatusRow(context, adjustedStatusFontSize, orderState,
                      onStatusPressed, postId),
                ],
              ),
              _buildTitleSection(context, title, adjustedTitleFontSize),
              _buildTagSection(context, tags, adjustedTagFontSize),
              _buildOrderInfoSection(
                  context, orderInfo, adjustedOrderInfoFontSize),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(BuildContext context, String postId) {
    HapticFeedback.selectionClick();
    onTap(postId);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PostDetailView(postId: postId),
      ),
    );
  }

  static Widget _buildImageSection(
      BuildContext context, List<Map<String, String>> imagesWithAltText) {
    final String imageToShow = imagesWithAltText.isNotEmpty
        ? imagesWithAltText[0]['url'] ?? ''
        : 'assets/images/sampleFoodPic.jpg';

    return Stack(
      children: [
        ClipRRect(
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
        ),
        Container(
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: [0.0, 0.5],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildTitleSection(
      BuildContext context, String title, double adjustedTitleFontSize) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
          fontSize: adjustedTitleFontSize,
          letterSpacing: -0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _buildTagSection(
      BuildContext context, List<String> tags, double adjustedTagFontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8, // Adjust spacing between tags if needed
        runSpacing: 8, // Space between lines
        children: tags
            .map((tag) => _buildTag(tag, _generateTagColor(tags.indexOf(tag)),
                context, adjustedTagFontSize))
            .toList(),
      ),
    );
  }

  static Color _generateTagColor(int index) {
    List<Color> availableColors = [yellow, orange, blue, babyPink, Cyan];
    return availableColors[index % availableColors.length];
  }

  static Widget _buildTag(String text, Color color, BuildContext context,
      double adjustedTagFontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4), // Adjusted padding
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
          color: color.computeLuminance() > 0.5
              ? CupertinoDynamicColor.resolve(CupertinoColors.black, context)
              : CupertinoDynamicColor.resolve(CupertinoColors.white, context),
          fontSize: adjustedTagFontSize,
          letterSpacing: -0.40,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow
            .ellipsis, // Changed to ellipsis to handle very long text
      ),
    );
  }

  static Widget _buildOrderInfoSection(BuildContext context, String orderInfo,
      double adjustedOrderInfoFontSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        orderInfo,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel, context),
          fontSize: adjustedOrderInfoFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _buildStatusRow(
      BuildContext context,
      double adjustedStatusFontSize,
      OrderState orderState,
      VoidCallback? onStatusPressed,
      String postId) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusText(context, adjustedStatusFontSize, orderState),
          _buildStatusButton(
              context, adjustedStatusFontSize, onStatusPressed, postId),
        ],
      ),
    );
  }

  static Widget _buildStatusText(BuildContext context,
      double adjustedStatusFontSize, OrderState orderState) {
    String statusText = '';
    Color statusColor = CupertinoColors.systemGreen; // Default color

    switch (orderState) {
      case OrderState.reserved:
        statusText = 'Reserved';
        statusColor = CupertinoColors.systemYellow;
        break;
      case OrderState.confirmed:
        statusText = 'Confirmed';
        statusColor = CupertinoColors.systemGreen;
        break;
      case OrderState.delivering:
        statusText = 'Delivering';
        statusColor = CupertinoColors.systemBlue;
        break;
      case OrderState.readyToPickUp:
        statusText = 'Ready to Pick Up';
        statusColor = CupertinoColors.systemGreen;
        break;
      case OrderState.pending:
        statusText = 'Pending';
        statusColor = CupertinoColors.systemOrange;
        break;
      case OrderState.notReserved:
        statusText = 'Not Reserved';
        statusColor = CupertinoColors.systemGrey;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        child: Row(
          children: [
            Icon(CupertinoIcons.circle_fill, color: statusColor, size: 12),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label, context),
                fontWeight: FontWeight.w500,
                fontSize: adjustedStatusFontSize,
              ),
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusButton(
      BuildContext context,
      double adjustedStatusFontSize,
      VoidCallback? onStatusPressed,
      String postId) {
    final buttonText = "Status";

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.selectionClick();
            onStatusPressed?.call();
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => DonorScreen(postId: postId),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: TextStyle(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.label, context),
                  fontWeight: FontWeight.w500,
                  fontSize: adjustedStatusFontSize,
                ),
                overflow: TextOverflow.visible,
              ),
              const SizedBox(width: 4),
              Icon(
                FeatherIcons.chevronRight,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label, context),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
