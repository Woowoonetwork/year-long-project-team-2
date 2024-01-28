import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';

const double _iconSize = 22.0;

class DonorRatingPage extends StatefulWidget {
  @override
  _DonorRatingPageState createState() => _DonorRatingPageState();
}

class _DonorRatingPageState extends State<DonorRatingPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle:
                Text('Donor Rating', style: TextStyle(letterSpacing: -1.34)),
            border: Border(bottom: BorderSide.none),
            backgroundColor: groupedBackgroundColor,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: _iconSize,
                  color: CupertinoColors.label.resolveFrom(context)),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoButton(
                  child: Text('Rate Donor'),
                  color: accentColor,
                  onPressed: () {
                    // Add action for the button here
                    print("Rate Donor button pressed");
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
