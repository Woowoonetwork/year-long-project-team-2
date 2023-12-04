import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main(){
  setUpAll(() async {

    // Ensure the test environment is set up correctly  
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock Firebase Analytics
    setupFirebaseAnalyticsMocks(); 

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });
  testWidgets('Create Post Screen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CupertinoApp(
      home: SettingsScreen(),
    ));
      
    // Verify that the Back arrow icon is rendered.
    expect(find.byIcon(CupertinoIcons.arrow_left), findsOneWidget, reason: "Back arrow icon not found");

    // Verify that the switch button for push notifications is present.
    expect(find.byType(CupertinoSwitch), findsOneWidget, reason: "Switch button not found");

    // Verify that the buttons are present.
    expect(find.byType(CupertinoButton), findsWidgets, reason: "1 or more buttons are missing");

  });
}