import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/edit_profile_screen.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockUser extends Mock implements User {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockUploadTask extends Mock implements UploadTask {}

void main() {
  // Initialize mock objects
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  final mockStorage = MockFirebaseStorage();
  final mockUser = MockUser();
  final mockDocumentSnapshot = MockDocumentSnapshot();
  final mockUploadTask = MockUploadTask();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Set up any necessary mock responses here
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserID');
    when(mockFirestore.collection('user').doc(any))
        .thenReturn(MockDocumentReference());
    when(mockStorage.ref(any)).thenReturn(MockReference());
  });

  group('EditProfilePage Tests', () {
    testWidgets('Verify UI Elements', (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(home: EditProfilePage()));
      // Add checks for various UI elements here
      expect(find.byType(CupertinoTextField), findsWidgets);
      expect(find.byIcon(FeatherIcons.x), findsOneWidget);
      expect(find.byType(CupertinoButton), findsWidgets);
      // ... More checks
    });

    testWidgets('Test Update Profile Functionality', (WidgetTester tester) async {
      when(mockFirestore.collection('user').doc('testUserID').get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({
        'firstName': 'Test',
        'lastName': 'User',
        'aboutMe': 'Test Bio',
        'email': 'test@example.com',
        // ... Add other fields as necessary
      });

      await tester.pumpWidget(CupertinoApp(home: EditProfilePage()));

      // Simulate user input
      await tester.enterText(find.byType(CupertinoTextField).at(0), 'Updated Name');
      // ... Continue for other fields

      // Tap the 'Save' button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify Firestore update method was called
      verify(mockFirestore.collection('user').doc('testUserID').update(argThat(
        isMapContaining({'firstName': 'Updated Name'}),
        // ... Add other updated fields
      ))).called(1);
    });

    testWidgets('Test Image Upload', (WidgetTester tester) async {
      // Assuming _uploadImageToFirebase is triggered on a button press
      when(mockStorage.ref('profile_images/profile_testUserID.jpg'))
          .thenReturn(MockReference());
      when(mockStorage.ref('profile_images/profile_testUserID.jpg').putFile(any))
          .thenReturn(mockUploadTask);
      when(mockUploadTask.whenComplete(any)).thenAnswer((_) async => null);
      when(mockStorage.ref('profile_images/profile_testUserID.jpg').getDownloadURL())
          .thenAnswer((_) async => 'http://example.com/downloadURL');

      await tester.pumpWidget(CupertinoApp(home: EditProfilePage()));
      // Simulate image upload
      // ... Your code to trigger _uploadImageToFirebase

      await tester.pumpAndSettle();

      // Verify that _uploadImageToFirebase is called
      verify(mockStorage.ref('profile_images/profile_testUserID.jpg').putFile(any)).called(1);
    });

    testWidgets('Test Error Handling', (WidgetTester tester) async {
      // Simulate error condition
      when(mockFirestore.collection('user').doc('testUserID').get())
          .thenThrow(Exception('Firestore error'));

      await tester.pumpWidget(CupertinoApp(home: EditProfilePage()));
      // Perform actions that would trigger the error
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert appropriate error handling
      expect(find.text('Error occurred'), findsOneWidget);
    });
  });
}
