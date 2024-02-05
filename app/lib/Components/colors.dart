import 'package:flutter/cupertino.dart';

/* 
  Use groupedBackgroundColor for the background color of any list views or grouped content.
  Use backgroundColor for the background color of any other content.
*/

const Color groupedBackgroundColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFEEEEEE), // Light grey for light mode
  darkColor: Color(0xFF222222), // Dark grey for dark mode
);

const Color backgroundColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF), // White for light mode
  darkColor: Color(0xFF000000), // Black for dark mode
);

const Color detailsBackgroundColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF), // White for light mode
  darkColor: Color(0xFF222222), // Black for dark mode
);

/* 
  Theme Colours
  Use accentColor for any primary action buttons or links.
  Use secondaryColor for any secondary action buttons or links.
  Use tertiaryColor for any tertiary action buttons or links.
  Use quaternaryColor for any quaternary action buttons or links.
*/

final CupertinoDynamicColor accentColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF337586),
  darkColor: Color(0xFF1B3C4A),
);

final CupertinoDynamicColor secondaryColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF9FD0C6),
  darkColor: Color(0xFF4f6a67),
);

final CupertinoDynamicColor tertiaryColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFFBFD7D2),
  darkColor: Color(0xFF72817e),
);

final CupertinoDynamicColor quaternaryColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFFD4E2DF),
  darkColor: Color(0xFF7f8785),
);

/* 
  Complementary colours
  Use complementary colours or any other labels such as tag colours.
*/

final CupertinoDynamicColor yellow = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFF9CF54),
  darkColor: Color(0xFF957c32),
);

final CupertinoDynamicColor orange = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFF8C5B),
  darkColor: Color(0xFF995436),
);

final CupertinoDynamicColor blue = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF42A9F4),
  darkColor: Color(0xFF276592),
);

final CupertinoDynamicColor babyPink = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFF8383),
  darkColor: Color(0xFF994e4e),
);

final CupertinoDynamicColor Cyan = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF05B7CF),
  darkColor: Color(0xFF036d7c),
);


/*

  Text Colours

  Use existing cupertino label colours for text colours.

  CupertinoColors.label - Use for text that contains primary content.
  CupertinoColors.secondaryLabel - Use for text that contains secondary content.
  CupertinoColors.tertiaryLabel - Use for text that contains tertiary content.
  CupertinoColors.quaternaryLabel - Use for text that contains quaternary content.

*/
