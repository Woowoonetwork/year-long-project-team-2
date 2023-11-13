import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/food_posting.dart';


void main() {
  testWidgets('FoodPosting UI Test', (WidgetTester tester) async {
    // Builds page
    await tester.pumpWidget(FoodPosting());

    // Verify that button is rendering correctly
    expect(find.text('Reserve'), findsOneWidget);

    // Verify that there is a heart button
    expect(find.byType(FloatingActionButton), findsOneWidget);

    /// Verify there are tags
    expect(find.byType(ListTile), findsNWidgets(8));

  });
}
