import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/posting_detail.dart';
import 'mock.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
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
  testWidgets('Posting page builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(home: PostDetailView()));

    expect(find.byType(AvailabilityIndicator), findsOneWidget,
        reason: 'availability indicator not found');
    expect(find.byType(InfoRow), findsOneWidget, reason: 'inforow not found');
    expect(find.byType(InfoCardsRow), findsOneWidget, reason: 'row not found');
    expect(find.byType(PickupInformation), findsOneWidget,
        reason: 'pickup info not found');
    expect(find.byType(AllergensSection), findsOneWidget,
        reason: 'allergens not found');
    expect(find.byType(ReserveButton), findsOneWidget,
        reason: 'reserve button not found');

    await tester.ensureVisible(find.byType(ReserveButton));
    await tester.tap(find.byType(ReserveButton));
    await tester.pump();
  });
}
