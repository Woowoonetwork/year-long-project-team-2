import 'package:FoodHood/Screens/food_posting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('FoodPosting UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(FoodPostingBig());

    // Verify that the back button is present.
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);

    // Verify that the heart and share buttons are present.
    expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.share), findsOneWidget);

    // Verify that the reserve button is present.
    expect(find.byType(CupertinoButton), findsWidgets);
  });
}
