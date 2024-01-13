import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:ui'; // Needed for ImageFilter

class CupertinoSearchNavigationBar extends StatelessWidget {
  final String title;
  final Border border;
  final Widget? trailing;
  final TextEditingController textController;
  final FocusNode _focusNode; // FocusNode for the search text field
  final Function _onSearchTextChanged; // Function to handle text changes
  final Widget Function()
      _buildFilterButton; // Function to build the filter button

  CupertinoSearchNavigationBar({
    Key? key,
    required this.title,
    required this.border,
    this.trailing,
    required this.textController,
    required FocusNode focusNode,
    required Function onSearchTextChanged,
    required Widget Function() buildFilterButton,
  })  : _focusNode = focusNode,
        _onSearchTextChanged = onSearchTextChanged,
        _buildFilterButton = buildFilterButton,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isFocused = _focusNode.hasFocus;

    return ClipRect(
        child: Container(
      decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
        groupedBackgroundColor,
        context,
      ).withOpacity(0.4)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: SafeArea(
          bottom: false,
          child: ClipRect(
            child: Padding(
              padding: EdgeInsets.all(16).copyWith(top: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                  ),
                  SizedBox(height: 8),
                  _buildSearchBar(
                      context, isFocused), // Search bar without Expanded
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildSearchBar(BuildContext context, bool isFocused) {
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
            placeholderStyle: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            style: TextStyle(
              fontSize: 18,
              color: CupertinoColors.label.resolveFrom(context),
            ),
            backgroundColor: CupertinoColors.tertiarySystemBackground,
            controller: textController,
            placeholder: 'Search',
            onChanged: (String value) {
              _onSearchTextChanged();
            },
          ),
        ),
        if (!isFocused) ...[
          SizedBox(width: 10),
          _buildFilterButton(),
        ],
      ],
    );
  }
}
