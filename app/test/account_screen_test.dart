import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/account_screen.dart'; // Adjust the import path
import 'package:FoodHood/Components/profile_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main() {
  group('AccountScreen Tests', () {

     setUpAll(() async {
    // This ensures the following code runs only once.
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAnalyticsMocks(); // Mock Firebase Analytics

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

    testWidgets('AccountScreen should display the necessary widgets', 
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(CupertinoApp(home: AccountScreen()));

        // Assert
        // Check for the presence of the ProfileCard
        expect(find.byType(ProfileCard), findsOneWidget);

        // Check for the presence of active orders text, as a proxy for the segmented control
        expect(find.text('Active Orders'), findsOneWidget);

        // Check for the presence of the Edit Profile button
        expect(find.text('Edit FoodHood Profile'), findsOneWidget);
        
    });

  });
}
