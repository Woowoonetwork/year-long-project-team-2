import 'package:FoodHood/firebase_mocks.dart';
import 'package:FoodHood/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:FoodHood/Screens/home_screen.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'mock.dart';
import 'mock_firestore_service.dart'; // Import your Firebase mock here

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

  group('Firestore Service Tests', () {
    MockFirestoreService? firestoreService;

    setUp(() {
      // Initialize the Firestore service before each test
      firestoreService = MockFirestoreService();
    });

    test('Read Document from Mock Firestore', () async {
      final service = firestoreService!;

      // Adding a document to firestore
      const collectionName = 'testCollection';
      const documentName = 'testDocument';
      const fieldNames = ['name', 'value'];
      const fieldValues = ['TestName', 'TestValue'];
      await service.addDocument(
        collectionName: collectionName,
        filename: documentName,
        fieldNames: fieldNames,
        fieldValues: fieldValues,
      );

      // Reading from the firebase
      final document = await service.readDocument(
        collectionName: collectionName,
        docName: documentName,
      );

      // Perform your assertions here for the mock Firestore service
      // For example:
      expect(document, isNotNull);
      expect(document?['value'], 'TestValue',
          reason: "Document should contain the correct 'value' field");
    });
  });

  // Separate testWidgets for UI testing
  testWidgets('Home Screen UI Test', (WidgetTester tester) async {
    // Build the HomeScreen widget
    await tester.pumpWidget(CupertinoApp(home: HomeScreen()));

    // Enter text into the search bar
    await tester.enterText(find.byType(CupertinoSearchTextField), 'TestValue');

    // Trigger a frame to rebuild the UI
    await tester.pumpAndSettle();

    // Check if PostCards are displayed
    // expect(find.byType(PostCard), findsWidgets);

    // Additional checks as needed...
  });
}
