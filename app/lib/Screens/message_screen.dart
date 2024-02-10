import 'package:FoodHood/Screens/home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Ensure these imports match the actual paths and package names in your Flutter project
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreenPage extends StatefulWidget {
  @override
  _MessageScreenPageState createState() => _MessageScreenPageState();
}

class _MessageScreenPageState extends State<MessageScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // Reduces the default spacing
        title: Row(
          children: <Widget>[
            // Custom back button with reduced padding
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              padding:
                  EdgeInsets.zero, // Reduces the padding around the icon button
              constraints:
                  BoxConstraints(), // Further reduces the space around the icon button
            ),
            Text(
              'Harry Styles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8), // Adjust the space as per your design
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 30), // Space after the status indicator
            // Faded "last seen a minute ago" text
            Text(
              'Last seen a minute ago',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6), // Makes the text faded
              ),
            ),
          ],
        ),
        automaticallyImplyLeading:
            false, // Prevents automatic insertion of a leading widget
      ),
      body: Center(
        child: Text('Message Screen Page'),
      ),
    );
  }
}
