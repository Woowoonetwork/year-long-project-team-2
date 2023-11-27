import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main(){
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

  });
}