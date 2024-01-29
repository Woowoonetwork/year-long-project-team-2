// This file creates a custom cupertino chip widget

import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';

class CupertinoChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;

  const CupertinoChipWidget({
    required this.label,
    this.onDeleted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4.0),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                color: CupertinoColors.white),
            ),
          ),
          
          // Delete the chip if the cross button is clicked
          if (onDeleted != null)
            GestureDetector(
              onTap: onDeleted,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 20.0,
                  color: CupertinoColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}