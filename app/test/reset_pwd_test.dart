import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/reset_pwd_screen.dart';

void main(){
  // This ensures the following firebase setup and initialization code runs only once.
  setUpAll(() async {

    // Ensure the test environment is set up correctly  
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Reset Password Screen UI Test', (WidgetTester tester) async {

     // Build our app and trigger a frame.
      await tester.pumpWidget(CupertinoApp(
        home: ForgotPasswordScreen(),
      ));

    // Verify that the Cancel button icon is rendered.
      expect(find.byIcon(CupertinoIcons.arrow_left_circle_fill), findsOneWidget, reason: "Cancel/Clear icon not found");
  });
}
