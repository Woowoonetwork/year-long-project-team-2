import 'dart:io';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'alt_text_editor.dart';
import 'package:flutter/services.dart';

class ImageTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;
  final Function(String altText) onAltTextChanged; // Add this line
  final bool hasAltText; // Add this line
  final String altText; // Add this line

  const ImageTile({
    Key? key,
    required this.imagePath,
    required this.onRemove,
    required this.onAltTextChanged,
    this.hasAltText = false, // Add this line, defaulting to false
    this.altText = '', // Add this line, defaulting to an empty string
  }) : super(key: key);

  void _showAltTextModal(BuildContext context) {
    HapticFeedback.mediumImpact(); // Add haptic feedback here
    showCupertinoModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return AltTextEditor(
          imagePath: imagePath,
          existingAltText: altText,
          onAltTextSaved: (newAltText) {
            onAltTextChanged(newAltText);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            File(imagePath),
            height: 150,
            width: 150,
            fit: BoxFit
                .fill, // Uses cover to maintain aspect ratio without stretching
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemGrey6
                          .resolveFrom(context)
                          .withOpacity(0.8)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      child: Icon(
                        FeatherIcons.x,
                        size: 16,
                        color: CupertinoColors.label
                            .resolveFrom(context)
                            .withOpacity(0.9),
                      ),
                      onTap: () {
                        HapticFeedback
                            .mediumImpact(); // Add haptic feedback here
                        onRemove();
                      },
                    ),
                  )),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: () {
              _showAltTextModal(context);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: hasAltText
                            ? blue
                            : CupertinoColors.systemGrey6
                                .resolveFrom(context)
                                .withOpacity(0.9)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '+ ALT',
                        style: TextStyle(
                          color: hasAltText
                              ? Colors.white
                              : CupertinoColors.label.resolveFrom(
                                  context), // Text color changes based on alt text existence
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ),
            ),
          ),
        ),
      ],
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
}
