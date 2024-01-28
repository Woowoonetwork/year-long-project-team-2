import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';

const double _iconSize = 22.0;
const double _defaultPadding = 16.0;
const double _defaultFontSize = 16.0;

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
            largeTitle: Text('', style: TextStyle(letterSpacing: -1.34)),
            border: Border(bottom: BorderSide.none),
            backgroundColor: groupedBackgroundColor,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: _iconSize,
                  color: CupertinoColors.label.resolveFrom(context)),
            ),
            trailing: GestureDetector(
              onTap: () {
                print("Message Harry Tapped");
              },
              child: Text(
                'Message Harry',
                style:
                    TextStyle(color: CupertinoColors.activeBlue, fontSize: 17),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100), // Adjust the height as needed
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _defaultPadding),
                  child: Text(
                    "How was your experience with Harry?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
