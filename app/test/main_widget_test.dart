import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart'; //

void main() {
  setUpAll(() async { // This ensures the following code runs only once.
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAnalyticsMocks(); // Mock Firebase Analytics

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  testWidgets('FoodHoodApp builds correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(FoodHoodApp());

    // Ensure that the app is successfully built.
    expect(find.byType(FoodHoodApp), findsOneWidget);
  });
}
