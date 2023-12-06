import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main(){
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAnalyticsMocks();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });
  testWidgets('Create Post Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: SettingsScreen(),
    ));
      
    expect(find.byIcon(CupertinoIcons.arrow_left), findsOneWidget, reason: "Back arrow icon not found");
    expect(find.byType(CupertinoSwitch), findsOneWidget, reason: "Switch button not found");
    expect(find.byType(CupertinoButton), findsWidgets, reason: "1 or more buttons are missing");
  });
}
