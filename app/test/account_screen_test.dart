import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/account_screen.dart'; // Adjust the import path
import 'package:FoodHood/Components/profile_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock_firestore_service.dart';
import 'mock.dart';

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

    test('Simulate Successful Document Addition', () async {
      // Arrange - setup phase for preparing the necessary preconditions and inputs for the test
      final firestoreService = MockFirestoreService();
      // Set simulateSuccess to true to simulate a successful operation
      firestoreService.simulateSuccess = true;

      // Act - Call the method that needs to be tested
      await firestoreService.addDocument(
        collectionName: 'mockCollection',
        filename: 'mockFilename',
        fieldNames: ['field1'],
        fieldValues: ['value1'],
      );

      // Asserts - Verifying the actual outcome matches the expected ones
      // Assert 1 - Check if simulateSuccess is still true after the operation
      expect(firestoreService.simulateSuccess, isTrue);

      // Retrieve the data from the mock service
      final addedData = await firestoreService.readDocument(
        collectionName: 'mockCollection',
        docName: 'mockFilename',
      );
      // Assert 2 - Check if the data contains the expected field name and value
      expect(addedData?['field1'], 'value1');
    });

    group('Firestore Service Tests', () {
      late MockFirestoreService
          mockFirestoreService; // Declare mockFirestoreService here

      setUp(() {
        mockFirestoreService = MockFirestoreService(); // Initialize it in setUp
      });

      test('Simulate Successful Document Addition', () async {
        // Arrange
        mockFirestoreService.simulateSuccess =
            true; // Simulate a successful operation
        final fieldNames = ['field1'];
        final fieldValues = ['value1'];

        // Act
        await mockFirestoreService.addDocument(
          collectionName: 'mockCollection',
          filename: 'mockFilename',
          fieldNames: fieldNames,
          fieldValues: fieldValues,
        );

        // Assert
        // Check if the document was added successfully
        final addedData = await mockFirestoreService.readDocument(
          collectionName: 'mockCollection',
          docName: 'mockFilename',
        );
        expect(addedData, isNotNull);
        expect(addedData?['field1'], 'value1');
      });

      test('Simulate Document Addition Failure', () async {
        // Arrange
        final firestoreService = MockFirestoreService();
        // Set simulateSuccess to false to simulate a failure
        firestoreService.simulateSuccess = false;

        // Act and Assert
        // Using expectLater handle the asynchronous nature
        expectLater(
          () => firestoreService.addDocument(
            collectionName: 'mockCollection',
            filename: 'mockFilename',
            fieldNames: ['field1'],
            fieldValues: ['value1'],
          ),
          throwsA(isInstanceOf<String>()),
        );

        // Check if simulateSuccess is still false after the operation
        expect(firestoreService.simulateSuccess, isFalse);

        //check if the data is not present after the failure
        final addedDataAfterFailure = await firestoreService.readDocument(
          collectionName: 'mockCollection',
          docName: 'mockFilename',
        );
        expect(addedDataAfterFailure, isNull);
      });
    });
  });
}
