import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Screens/orders_sheet.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:FoodHood/auth_service.dart';
import 'package:flutter/cupertino.dart';

void main() {
  group('OrdersScreen Tests', () {
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

     testWidgets('Renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: OrdersScreen()));

      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Past Orders'), findsOneWidget);

    });
    testWidgets('Switches between tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: OrdersScreen()));

      await tester.tap(find.text('Past Orders'));
      await tester.pumpAndSettle(); // Wait for all animations and state changes to complete

      expect(find.text('Past orders will appear here'), findsOneWidget);
    });

  });
}
