import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/registration_screen.dart';
import 'package:FoodHood/auth_service.dart';
import 'package:FoodHood/Screens/home_screen.dart';

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
      // No need to create a new instance here since it's already being created inside the CupertinoApp below
      // final registrationScreen = RegistrationScreen(auth: mockAuthService);

      await tester.pumpWidget(
        CupertinoApp(
          home: RegistrationScreen(auth: mockAuthService),
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == '/home') {
              return CupertinoPageRoute(
                builder: (context) =>
                    HomeScreen(), // HomeScreen is the destination after successful registration
              );
            }
            // Handle undefined routes
            return CupertinoPageRoute(
              builder: (context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text('Page Not Found'),
                ),
                child: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Fill in the registration form fields
      // Ensure that the number of fields and their order matches the form fields in the widget
      await tester.enterText(find.byType(CupertinoTextField).at(0), 'John');
      await tester.enterText(find.byType(CupertinoTextField).at(1), 'Doe');
      await tester.enterText(
          find.byType(CupertinoTextField).at(2), 'john@example.com');
      await tester.enterText(
          find.byType(CupertinoTextField).at(3), 'password123');
      await tester.enterText(
          find.byType(CupertinoTextField).at(4), 'California');
      await tester.enterText(
          find.byType(CupertinoTextField).at(5), 'Los Angeles');

      // Trigger the button press to create an account
      await tester.tap(find.widgetWithText(CupertinoButton, 'Create account'));
      await tester
          .pumpAndSettle(); // This should be pumpAndSettle to allow any navigation animations to complete

      // Verify that the registration was successful by checking if HomeScreen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
