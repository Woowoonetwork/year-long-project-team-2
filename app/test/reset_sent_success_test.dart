import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/login_screen.dart';
import 'package:FoodHood/Screens/reset_sent_success.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('SuccessScreen UI Tests', () {
    late NavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    testWidgets('Check if all elements are present',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: SuccessScreen(message: 'Test Message'),
          navigatorObservers: [mockObserver],
        ),
      );

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);

      expect(find.text('Success!'), findsOneWidget);

      expect(
          find.text(
              "Your password reset link has been sent!\n Please follow the instructions in your email and we'll see you soon!"),
          findsOneWidget);

      expect(find.text('Continue to FoodHood'), findsOneWidget);
    });
  });
}
