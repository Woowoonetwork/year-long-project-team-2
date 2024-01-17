import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';

// Bouncing Widget
class Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPress;

  const Bouncing({required this.child, Key? key, this.onPress})
      : super(key: key);

  @override
  _BouncingState createState() => _BouncingState();
}

class _BouncingState extends State<Bouncing>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPress != null) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (widget.onPress != null) {
          _controller.reverse();
          widget.onPress!();
        }
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

// FoodAppBar
class FoodAppBar extends StatefulWidget {
  const FoodAppBar({Key? key}) : super(key: key);

  @override
  _FoodAppBarState createState() => _FoodAppBarState();
}

class _FoodAppBarState extends State<FoodAppBar> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      expandedHeight: 300,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [
          StretchMode.zoomBackground, // Allow the background to zoom
          StretchMode.blurBackground, // Apply blur effect for a nice transition
        ],
        background:
            Image.asset('assets/images/chickenrice.jpeg', fit: BoxFit.cover),
      ),
      leading: _buildLeading(context),
      actions: [_buildFavoriteButton(context), _buildShareButton(context)],
    );
  }

  Widget _buildLeading(BuildContext context) {
    return _blurEffect(
      CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(FeatherIcons.chevronLeft,
            size: 20, color: CupertinoColors.label.resolveFrom(context)),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return _blurEffect(
      Bouncing(
        onPress: () {
          setState(() => isFavorite = !isFavorite);
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: isFavorite
              ? CupertinoColors.systemRed
              : CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return _blurEffect(
      CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(
          FeatherIcons.share,
          size: 18,
          color: CupertinoColors.label.resolveFrom(context),
        ),
        onPressed: () {
          Share.share(
              'Check out this food post!'); // Replace with your actual share message
        },
      ),
    );
  }

  Widget _blurEffect(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: CupertinoColors.secondarySystemBackground
                .resolveFrom(context)
                .withOpacity(0.8),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
