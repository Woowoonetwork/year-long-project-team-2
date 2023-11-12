import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/create_post.dart';

void main(){
  testWidgets('Create Post Screen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: CreatePostScreen(),
    ));
      
    // Verify that the Save button text is rendered.
    expect(find.text('Save'), findsOneWidget, reason: "Save text not found");
    // Verify that the Cancel button icon is rendered.
    expect(find.byIcon(Icons.close), findsOneWidget, reason: "Cancel/Close icon not found");

    // Verify that both buttons are present
    expect(find.byType(ElevatedButton), findsOneWidget, reason: "Save button not found");
    expect(find.byType(IconButton), findsOneWidget, reason: "Cancel button not found");

    // Verify that the text input fields for title, description, alt text, search bars for allergens and tags, and pickup instructions are present
    expect(find.byType(TextField), findsWidgets, reason: "1 or more text fields are missing");

    // Verify that the search bar text is present for 2 widgets
    expect(find.widgetWithText(TextField, 'Search'), findsNWidgets(2), reason: "1 or more search bar is missing");

    // Verify that the TimePicker is present.
    expect(find.byType(TimePickerDialog), findsOneWidget, reason: "Time picker is not found");

    // Verify that the TimePicker is present.
    expect(find.byType(DatePickerDialog), findsOneWidget, reason: "Date picker is not found");

  });
}