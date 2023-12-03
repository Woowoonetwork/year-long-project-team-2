import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main() async{
  
  // This ensures the following firebase setup and initialization code runs only once.
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
  
  testWidgets('Create Post Screen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CupertinoApp(
      home: CreatePostScreen(),
    ));
      

    // Verify that the Cancel button icon is rendered.
    expect(find.byIcon(CupertinoIcons.clear), findsOneWidget, reason: "Cancel/Clear icon not found");

    // Verify that both buttons (save and cancel) are present
    expect(find.byType(CupertinoButton), findsNWidgets(2), reason: "Save or Cancel button not found");

    // Verify that the text input fields for title, description, and pickup instructions are present
    expect(find.byType(CupertinoTextField), findsWidgets, reason: "1 or more text input fields are missing");

    // Verify that the search bars are present
    expect(find.byType(CupertinoSearchTextField), findsWidgets, reason: "1 or more search bars are missing");
    
    // Verify that the Date Pickers (for date and time) are present
    expect(find.byType(CupertinoDatePicker), findsWidgets, reason: "A date picker is not found");

    // Verify that the Google Map widget is present
    //expect(find.byType(GoogleMap), findsOneWidget);

    // Test functionality upon clicking on the "Save" button
    // Find the "Save" button and tap it
    await tester.tap(find.text('Save'));
    // Wait for animations to complete
    await tester.pumpAndSettle();
    // Verify that the confirmation dialogue appears
    expect(find.text('Missing Information'), findsOneWidget);
    expect(find.text('Please enter all the information before saving.'), findsOneWidget);
    // Tap the "OK" button in the confirmation dialogue
    await tester.tap(find.text('OK'));
    // Wait for animations to complete
    await tester.pumpAndSettle();
    // Verify that the screen is still open (not popped)
    expect(find.byType(CreatePostScreen), findsOneWidget);

    // Test functionality upon clicking the "cancel" button
    // Find the Cancel button icon and tap it
    await tester.tap(find.byIcon(CupertinoIcons.clear));
    // Wait for animations to complete
    await tester.pumpAndSettle();
    // Verify that the confirmation dialogue appears
    expect(find.text('Confirm Exit'), findsOneWidget);
    expect(find.text('Are you sure you want to discard your changes?'), findsOneWidget);
    // Tap the "Discard" button in the confirmation dialogue
    await tester.tap(find.text('Discard'));
    // Wait for animations to complete
    await tester.pumpAndSettle();
    // Verify that the screen is popped (closed)
    expect(find.byType(CreatePostScreen), findsNothing);

  });
}