// This file creates a custom cupertino chip widget

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
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(51, 117, 134, 0.8),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          
          // Delete the chip if the cross button is clicked
          if (onDeleted != null)
            GestureDetector(
              onTap: onDeleted,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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