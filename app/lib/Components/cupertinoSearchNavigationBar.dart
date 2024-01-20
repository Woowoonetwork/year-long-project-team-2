import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:ui'; // Needed for ImageFilter

class CupertinoSearchNavigationBar extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final TextEditingController textController;
  final Function(String) onSearchTextChanged;
  final Widget Function() buildFilterButton;

  const CupertinoSearchNavigationBar({
    Key? key,
    required this.title,
    this.trailing,
    required this.textController,
    required this.onSearchTextChanged,
    required this.buildFilterButton,
  }) : super(key: key);

  @override
  _CupertinoSearchNavigationBarState createState() =>
      _CupertinoSearchNavigationBarState();
}

class _CupertinoSearchNavigationBarState
    extends State<CupertinoSearchNavigationBar> {
  late FocusNode _focusNode;
  bool _showCancelButton = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.textController.addListener(_updateCancelButtonVisibility);
  }

  void _updateCancelButtonVisibility() {
    final shouldShow = widget.textController.text.isNotEmpty;
    if (_showCancelButton != shouldShow) {
      setState(() {
        _showCancelButton = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.textController.removeListener(_updateCancelButtonVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGroupedBackground, context)
              .withOpacity(0.4),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 48),
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

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 34,
              letterSpacing: -1.3,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label.resolveFrom(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            suffixIcon: const Icon(
              FeatherIcons.x,
              size: 20,
            ),
            placeholderStyle: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.label.resolveFrom(context),
            ),
            backgroundColor: CupertinoColors.tertiarySystemBackground,
            controller: widget.textController,
            placeholder: 'Search',
            onChanged: (text) {
              widget.onSearchTextChanged(text);
              _updateCancelButtonVisibility();
            },
            focusNode: _focusNode,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween(
                begin: 1.0,
                end: 1.0,
              ).animate(animation),
              child: child,
            );
          },
          child: _showCancelButton
              ? _buildCancelButton(context)
              : widget.buildFilterButton(),
          key: ValueKey(_showCancelButton),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      height: 20,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          widget.textController.clear();
          widget.onSearchTextChanged(
              ''); // Clear the text and pass an empty string to the callback
          _updateCancelButtonVisibility();
        },
        child: Text(
          'Cancel',
          style: TextStyle(
            color: CupertinoColors.activeBlue.resolveFrom(context),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
