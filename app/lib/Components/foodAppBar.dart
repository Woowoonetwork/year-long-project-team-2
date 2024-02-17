import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FoodAppBar extends StatefulWidget {
  final String postId;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;
  final List<String> imageUrls;

  const FoodAppBar({
    Key? key,
    required this.postId,
    required this.onFavoritePressed,
    required this.isFavorite,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _FoodAppBarState createState() => _FoodAppBarState();
}

class _FoodAppBarState extends State<FoodAppBar> {
  final PageController _pageController = PageController();

  bool _showIndicator = false;
  bool _showAltText = false;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_pageController.page != null) {
      if (!_showIndicator) {
        setState(() => _showIndicator = true);
      }
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showIndicator = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      expandedHeight: 340,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildBackgroundImage(),
            AnimatedOpacity(
              opacity: _showIndicator ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: _buildPageIndicator(
                  _pageController,
                  CupertinoDynamicColor.resolve(detailsBackgroundColor, context)
                      .withOpacity(0.8)),
            ),
          ],
        ),
      ),
      leading: _buildLeading(context),
      actions: [_buildFavoriteButton(context), _buildShareButton(context)],
    );
  }

  Widget _buildLeading(BuildContext context) {
    return _blurEffect(
      CircleAvatar(
        backgroundColor: Colors.transparent,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(FeatherIcons.chevronLeft,
              size: 20, color: CupertinoColors.label.resolveFrom(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      CupertinoColors.secondarySystemBackground
          .resolveFrom(context)
          .withOpacity(0.8),
      () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBackgroundImage() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        final String imageUrl = widget.imageUrls[index];
        return GestureDetector(
          onTap: () => _openPhotoGalleryView(context, index),
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: CupertinoColors.systemOrange,
                  size: 60),
            ),
          ),
        );
      },
    );
  }

  // Ensuring ALT text is shown based on _showAltText
  Widget _buildAltTextBox() {
    if (!_showAltText) return Container(); // If _showAltText is false, don't show the ALT text box.

    return Positioned(
      bottom: 100, // Adjust as needed
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Alternative Text Displayed Here",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAltButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:
                    _showAltText ? blue : CupertinoColors.darkBackgroundGray),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _showAltText = !_showAltText;
                });
              },
              child: Text(
                'ALT',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
    );
  }

  void _openPhotoGalleryView(BuildContext context, int initialIndex) {
    PageController galleryPageController =
        PageController(initialPage: initialIndex);

    Navigator.of(context).push(
      smoothRoute(
        Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: _blurEffect(
              Icon(FeatherIcons.x, size: 20, color: CupertinoColors.white),
              CupertinoColors.darkBackgroundGray,
              () => Navigator.of(context).pop(),
            ),
            actions: [_buildAltButton()],
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.imageUrls.length,
                builder: (context, index) {
                  final String imageUrl = widget.imageUrls[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(imageUrl),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                    onTapUp: (context, details, controllerValue) {
                      Navigator.of(context).pop(); // Close gallery on tap
                    },
                  );
                },
                pageController: galleryPageController,
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) =>
                    Center(child: CircularProgressIndicator()),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildPageIndicator(galleryPageController,
                    CupertinoColors.darkBackgroundGray.withOpacity(0.8)),
              ),
              if (_showAltText) _buildAltTextBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return _blurEffect(
      Icon(
        widget.isFavorite ? Icons.bookmark : Icons.bookmark_add_outlined,
        size: 18,
        color: widget.isFavorite
            ? CupertinoColors.systemOrange
            : CupertinoColors.label.resolveFrom(context),
      ),
      CupertinoColors.secondarySystemBackground
          .resolveFrom(context)
          .withOpacity(0.8),
      widget.onFavoritePressed,
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return _blurEffect(
      Icon(FeatherIcons.share,
          size: 18, color: CupertinoColors.label.resolveFrom(context)),
      CupertinoColors.secondarySystemBackground
          .resolveFrom(context)
          .withOpacity(0.8),
      () => Share.share('Check out this food post!'),
    );
  }

  Widget _blurEffect(
      Widget child, Color backgroundColor, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: child,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(
      PageController pageController, Color backgroundColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: backgroundColor),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: widget.imageUrls.length,
                  effect: WormEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      type: WormType.underground,
                      dotColor:
                          CupertinoColors.systemGrey2.resolveFrom(context),
                      activeDotColor: accentColor),
                ),
              )),
        ),
      ),
    );
  }
}
