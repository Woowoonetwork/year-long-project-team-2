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

const double _defaultTextFontSize = 16.0;
const double _defaultTitleFontSize = 18.0;
const double _defaultTagFontSize = 10.0;
const double _defaultOrderInfoFontSize = 12.0;
const double _defaultStatusFontSize = 13.0;
const double imageHeight = 120;

enum OrderState { reserved, confirmed, delivering, readyToPickUp, pending, notReserved}

// ignore: must_be_immutable
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
  late double _textScaleFactor;
  late double adjustedTextFontSize;
  late double adjustedTitleFontSize;
  late double adjustedTagFontSize;
  late double adjustedOrderInfoFontSize;
  late double adjustedStatusFontSize;
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

  void _updateAdjustedFontSize() {
    adjustedTextFontSize = _defaultTextFontSize * _textScaleFactor;
    adjustedTitleFontSize = _defaultTitleFontSize * _textScaleFactor;
    adjustedTagFontSize = _defaultTagFontSize * _textScaleFactor;
    adjustedOrderInfoFontSize = _defaultOrderInfoFontSize * _textScaleFactor;
    adjustedStatusFontSize = _defaultStatusFontSize * _textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    _textScaleFactor = Provider.of<TextScaleProvider>(context).textScaleFactor;
    _updateAdjustedFontSize();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onCardTap(context),
        child: _buildCardBody(context),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, VoidCallback action) {
    action();
    Navigator.pop(context);
  }

  void _onCardTap(BuildContext context) {
    onTap(postId);
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PostDetailView(postId: postId),
        ));
  }

  Widget _buildCardBody(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImageSection(context),
              _buildStatusRow(context),
            ],
          ),
          _buildTitleSection(context),
          _buildTagSection(context),
          _buildOrderInfoSection(context),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
      borderRadius: BorderRadius.circular(14),
    );
  }

  Widget _buildImageSection(BuildContext context) {
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

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(title,
          style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: adjustedTitleFontSize,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTagSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 7,
        children: tags
            .map((tag) =>
                _buildTag(tag, _generateTagColor(tags.indexOf(tag)), context))
            .toList(),
      ),
    );
  }

  Color _generateTagColor(int index) {
    List<Color> availableColors = [yellow, orange, blue, babyPink, Cyan];
    return availableColors[index % availableColors.length];
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
            color:
                CupertinoDynamicColor.resolve(CupertinoColors.black, context),
            fontSize: adjustedTagFontSize,
            letterSpacing: -0.40,
            fontWeight: FontWeight.w600),
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(orderInfo,
          style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontSize: adjustedOrderInfoFontSize,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusText(context),
          _buildStatusButton(context),
        ],
      ),
    );
  }

  Widget _buildStatusText(BuildContext context) {
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: CupertinoColors.tertiarySystemBackground
              .resolveFrom(context)
              .withOpacity(0.9),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _handleStatusPress(context),
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
                      fontSize: adjustedStatusFontSize),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur filter
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _handleStatusPress(context),
            child: Row(
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, context),
                      fontWeight: FontWeight.w500,
                      fontSize: adjustedStatusFontSize),
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(width: 4),
                Icon(FeatherIcons.chevronRight,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.label, context),
                    size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStatusPress(BuildContext context) {
    onStatusPressed?.call();
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => DonorScreen(postId: postId),
        ));
  }
}
