import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/registration_screen.dart';
import 'package:FoodHood/auth_service.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser user;
    late AuthService mockAuthService;

    setUp(() {
      user = MockUser(
        isAnonymous: false,
        uid: 'someuid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockFirebaseAuth = MockFirebaseAuth(mockUser: user);
      mockAuthService = AuthService(mockFirebaseAuth);
    });

     testWidgets('Successful Registration Test', (WidgetTester tester) async {
      // Use the mockAuthService when creating the RegistrationScreen
      final registrationScreen = RegistrationScreen(auth: mockAuthService);

      // Wrap the RegistrationScreen with a CupertinoApp
      await tester.pumpWidget(CupertinoApp(home: registrationScreen));

      await tester.pumpAndSettle();

      // Fill in the registration form with valid data
      // await tester.enterText(find.byType(CupertinoTextField).at(0), 'John');
      // await tester.enterText(find.byType(CupertinoTextField).at(1), 'Doe');
      await tester.enterText(
          find.byType(CupertinoTextField).at(2), 'john@example.com');
      await tester.enterText(
          find.byType(CupertinoTextField).at(3), 'password123');
      // await tester.enterText(find.byType(CupertinoTextField).at(4), 'California');
      // await tester.enterText(find.byType(CupertinoTextField).at(5), 'Los Angeles');

      // Trigger the button press to create an account
      await tester.tap(find.widgetWithText(CupertinoButton, 'Create account'));
      await tester.pump();

      // Verify that the registration was successful
      final user = mockFirebaseAuth.currentUser;
      expect(user, isNotNull);
    });
  });
}
