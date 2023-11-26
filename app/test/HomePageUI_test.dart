import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/home_screen.dart';

void main() {
  testWidgets('Check for search bar, buttons, and list in MyWidget',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(),
    ));

    // Check for the presence of a search bar (text editor field)
    expect(find.byType(Text), findsWidgets);

    // Check for the presence of buttons
    expect(find.byType(CupertinoButton), findsWidgets);

    // Check for the presence of a list
    expect(find.byType(CupertinoSearchTextField), findsWidgets);
    // expect(find.byType(ListView), findsOneWidget);
  });
}
