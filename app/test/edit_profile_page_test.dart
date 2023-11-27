import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/profile_edit_screen.dart'; // Adjust the import path
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main() {
  setUpAll(() async {
    // This ensures the following code runs only once.
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAnalyticsMocks(); // Mock Firebase Analytics

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  group('EditProfilePage Tests', () {
    // Arrange
    testWidgets('EditProfilePage should display profile form fields',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(CupertinoApp(
        home: EditProfilePage(), // Your EditProfilePage
      ));

      // Assert
      expect(find.byType(CupertinoTextField),
          findsWidgets); // Check if text fields are present
      expect(find.byType(Text).at(0),
          findsOneWidget); // Find the first Text widget
      expect(find.byType(CupertinoTextField),
          findsWidgets); // Find all CupertinoTextField widgets

      // ... other assertions ...
    });

    // Add more tests as needed
  });
}
