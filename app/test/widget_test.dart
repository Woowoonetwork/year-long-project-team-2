import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/login_screen.dart'; // Replace 'your_app' with your actual package name
import 'package:flutter/cupertino.dart';

void main() {
  testWidgets('Check for at least one Text widget and one ElevatedButton in LogInScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );

    // Use the `find.byType` and `expect` functions to check for the presence of the elements
    expect(find.byType(Text), findsWidgets);
    expect(find.byType(CupertinoButton), findsWidgets);
  });
}
