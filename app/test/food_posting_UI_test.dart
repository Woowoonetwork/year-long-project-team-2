import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/food_posting.dart';


void main() {
  testWidgets('FoodPosting UI Test', (WidgetTester tester) async {
    // Builds page
    await tester.pumpWidget(FoodPosting());

    // Verify that bar is rendering correctly
    expect(find.text('Scrollable List Example'), findsOneWidget);

    // Verify that there is a scrollable list
    expect(find.byType(ListView), findsOneWidget);

    /// Verify there are 50 items in list, this number should be changed
    expect(find.byType(ListTile), findsNWidgets(50));

  });
}
