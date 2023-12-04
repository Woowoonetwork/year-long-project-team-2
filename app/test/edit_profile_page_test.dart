import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/edit_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:feather_icons/feather_icons.dart';
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

  group('Edit Profile Test', () {
    testWidgets('Edit Profile Screen UI Test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(CupertinoApp(
        home: EditProfilePage(),
      ));

      // Verify that the close icon is rendered.
      expect(find.byIcon(FeatherIcons.x), findsOneWidget);

      // Verify that the "Save" button is present
      expect(find.text('Save'), findsOneWidget);

      // Verify that the text input fields for first name, last name, about me, and email are present
      expect(find.byType(CupertinoTextField), findsNWidgets(4));

      // Verify that the profile image uploader is present
      expect(find.text('Upload Profile Picture'), findsOneWidget);

      // Verify that the action buttons for "Reset Password" and "Delete Account" are present
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Test functionality upon clicking on the "Save" button
      // Find the "Save" button and tap it
      await tester.tap(find.text('Save'));
      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Since we don't have a real backend, we cannot verify the actual update operation.
      // In a real test, you would mock the backend response and verify if the profile was updated.

      // Test functionality upon clicking the "Close" icon
      // Find the Close icon and tap it
      await tester.tap(find.byIcon(FeatherIcons.x));
      // Wait for animations to complete
      await tester.pumpAndSettle();
      // Verify that the screen is popped (closed)
      expect(find.byType(EditProfilePage), findsNothing);
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
    late MockFirestoreService mockFirestoreService; // Declare mockFirestoreService here

    setUp(() {
      mockFirestoreService = MockFirestoreService(); // Initialize it in setUp
    });

    test('Simulate Successful Document Addition', () async {
      // Arrange
      mockFirestoreService.simulateSuccess = true; // Simulate a successful operation
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
