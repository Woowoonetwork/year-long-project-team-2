import 'dart:ui';

import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Post {
  final String id;
  final String title;

  Post({required this.id, required this.title});
}

class CupertinoSearchNavigationBar extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final FocusNode focusNode;
  final TextEditingController textController;
  final Function(String) onSearchTextChanged;
  final Widget Function() buildFilterButton;
  final VoidCallback onSearchBarTapped;
  final VoidCallback onClearSearch;

  const CupertinoSearchNavigationBar({
    super.key,
    required this.title,
    this.trailing,
    required this.focusNode,
    required this.textController,
    required this.onSearchTextChanged,
    required this.buildFilterButton,
    required this.onSearchBarTapped,
    required this.onClearSearch,
  });

  @override
  _CupertinoSearchNavigationBarState createState() =>
      _CupertinoSearchNavigationBarState();
}

class _CupertinoSearchNavigationBarState
    extends State<CupertinoSearchNavigationBar> {
  late FocusNode _focusNode;
  bool _showCancelButton = false;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(groupedBackgroundColor, context)
              .withOpacity(0.4),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildSearchBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onSearchBarFocusChange);
    _focusNode.dispose();
    widget.textController.removeListener(_updateCancelButtonVisibility);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onSearchBarFocusChange);
    widget.textController.addListener(_updateCancelButtonVisibility);
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: 20,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          widget.textController.clear();
          widget.onSearchTextChanged('');
          _focusNode.unfocus();
          widget.onClearSearch();
        },
        child: Text(
          'Cancel',
          style: TextStyle(
            color: accentColor.resolveFrom(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            suffixIcon: Icon(
              FeatherIcons.x,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              size: 20,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 6.0, top: 2.0),
              child: const Icon(
                FeatherIcons.search,
                size: 18.0,
              ),
            ),
            placeholder: 'Search Nearby',
            placeholderStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.label.resolveFrom(context),
            ),
            backgroundColor: CupertinoColors.tertiarySystemBackground,
            controller: widget.textController,
            onChanged: (text) {
              widget.onSearchTextChanged(text);
              _updateCancelButtonVisibility();
              if (text.isEmpty) {
                widget.onClearSearch();
              }
            },
            focusNode: _focusNode,
            onSubmitted: (text) {
              _focusNode.unfocus();
            },
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            );
          },
          child: _showCancelButton
              ? _buildCancelButton(context)
              : widget.buildFilterButton(),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 47),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 34,
                  letterSpacing: -1.3,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onSearchBarFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showCancelButton = true;
      });
      widget.onSearchBarTapped();
    } else {
      _updateCancelButtonVisibility();
    }
  }

  void _updateCancelButtonVisibility() {
    final shouldShow =
        widget.textController.text.isNotEmpty || _focusNode.hasFocus;
    if (_showCancelButton != shouldShow) {
      setState(() {
        _showCancelButton = shouldShow;
      });
    }
  }
}
