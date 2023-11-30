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

/* 
  Accent Color
  Use accentColor for any primary action buttons or links.
*/

final CupertinoDynamicColor accentColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF337586),
  darkColor: Color(0xFF1B3C4A),
);
