import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/settings_screen.dart';

void main(){
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