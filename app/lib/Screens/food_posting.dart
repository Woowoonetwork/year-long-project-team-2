import 'package:flutter/material.dart';

class FoodPosting extends StatefulWidget {
  const FoodPosting({Key? key}) : super(key: key);

  @override
FoodPostingState createState() =>FoodPostingState();
}

class FoodPostingState extends State<FoodPosting> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scrollable List Example'),
        ),
        body: MyScrollableList(),
      ),
    );
  }
}

class MyScrollableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50, // Set the number of items in the list
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          // Add more customization as needed
        );
      },
    );
  }
}

void main() {
  runApp(FoodPosting());
}
