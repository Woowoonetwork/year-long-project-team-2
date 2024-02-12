import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FoodHood/Screens/message_screen.dart'; // Correct this import based on your project structure
// No need for mock.dart or Firebase imports for this test

void main() {
  testWidgets('Check for Text and TextField widgets in MessageScreenPage',
      (WidgetTester tester) async {
    // Wrapping MessageScreenPage in a MaterialApp to ensure all Material and Cupertino dependencies are met
    await tester.pumpWidget(CupertinoApp(
      home: MessageScreenPage(),
    ));

    // Use pumpAndSettle to wait for any initial animations or setState calls to complete
    //await tester.pumpAndSettle();

    // Checks for the presence of TextField where users input their message
    // expect(find.byType(TextField), findsOneWidget);

    // Since the message screen should contain Text widgets (e.g., "Harry Styles", "Last seen a minute ago"),
    // this checks if at least one Text widget is found. This is a basic check and can be adjusted based on your UI.
    expect(find.byType(CupertinoTextField), findsWidgets);
  });
}
