import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/login_screen.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart'; //

void main() {

  setUpAll(() async { // This ensures the following code runs only once.
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAnalyticsMocks(); // Mock Firebase Analytics

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });
  
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
