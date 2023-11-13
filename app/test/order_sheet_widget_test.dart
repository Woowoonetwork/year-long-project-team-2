import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Screens/orders_sheet.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:FoodHood/auth_service.dart';


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
      // Render the PastOrdersScreen
      await tester.pumpWidget(OrdersScreen());

      // Check if 'Active Orders' and 'Past Orders' segments are found
      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Past Orders'), findsOneWidget);

      // Check for the presence of OrderCard in 'Active Orders'
      await tester.tap(find.text('Active Orders'));
      await tester.pump();
      expect(find.byType(OrderCard), findsWidgets);
    });

    testWidgets('Switches between tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(OrdersScreen());

      // Switch to 'Past Orders'
      await tester.tap(find.text('Past Orders'));
      await tester.pump();

      // Check for 'Past orders will appear here' text
      expect(find.text('Past orders will appear here'), findsOneWidget);
    });

    testWidgets('Modal Bottom Sheet displays correctly',
        (WidgetTester tester) async {
      // Render a widget that calls showPastOrdersSheet
      // Test if the PastOrdersScreen is displayed as a modal when showPastOrdersSheet is called
    });

    // Additional tests as needed...
  });
}
