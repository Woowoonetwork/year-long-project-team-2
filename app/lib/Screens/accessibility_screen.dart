import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

const double _iconSize = 22.0;
const double _defaultPadding = 16.0;
const double _defaultFontSize = 16.0;

class AccessibilityScreen extends StatefulWidget {
  @override
  _AccessibilityScreenState createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  late double _textScaleFactor; // Initial text scale factor

  @override
  void initState() {
    super.initState();
    _textScaleFactor = Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
              largeTitle: Text('Accessibility', style: TextStyle(letterSpacing: -1.34)),
              border: Border(bottom: BorderSide.none),
              backgroundColor: groupedBackgroundColor,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(FeatherIcons.chevronLeft,
                    size: _iconSize, color: CupertinoColors.label.resolveFrom(context)),
              ),
            ),
          CupertinoSliverRefreshControl(onRefresh: () async {}),
          SliverToBoxAdapter(
            child: Consumer<TextScaleProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.0),
                    Padding(
                      padding: EdgeInsets.only(left: _defaultPadding),
                      child: Text(
                        "Text Size",
                        style: TextStyle(
                          fontSize: _defaultFontSize * provider.textScaleFactor,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity, // Use double.infinity to fill available width
                          child: CupertinoSlider(
                            activeColor: accentColor,
                            value: provider.textScaleFactor,
                            min: 1.0,
                            max: 2.0,
                            onChanged: (value) {
                              provider.textScaleFactor = value;
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.0),
                    // Padding(
                    //   padding: EdgeInsets.all(_defaultPadding),
                    //   child: Text(
                    //     "Contrast Mode",
                    //     style: TextStyle(
                    //       fontSize: _defaultFontSize * provider.textScaleFactor,
                    //       letterSpacing: -0.8,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

