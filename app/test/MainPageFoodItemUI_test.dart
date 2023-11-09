import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/MainPageFoodList.dart'; // Replace 'your_app' with your actual package name

void main() {
  testWidgets('Check for search bar, buttons, and list in MyWidget',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: MainPageFoodList.dart(),
    ));

    // Check for the presence of a search bar (text editor field)
    expect(find.byType(TextField), findsOneWidget);

    // Check for the presence of buttons
    expect(find.byType(ElevatedButton), findsWidgets);

    // Check for the presence of a list
    expect(find.byType(ListView), findsOneWidget);
  });
}
