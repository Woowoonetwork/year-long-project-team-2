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
    expect(find.text('Save'), findsOneWidget);
    // Verify that the Cancel button icon is rendered.
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Verify that both buttons are present
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);

    //Verify the text input fields for title, description, alt text, and pickup instructions are present
    expect(find.byType(TextField), findsNWidgets(4));
  });
}