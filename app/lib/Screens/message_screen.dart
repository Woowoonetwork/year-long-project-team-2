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
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            Text(
              'Harry Styles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 30),
            Text(
              'Last seen a minute ago',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 35.0, left: 8.0, right: 8.0), // Increased top padding
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns the message to the left
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              padding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0), // Reduced padding inside the container
              decoration: BoxDecoration(
                color: Colors.grey[300], // Background color of the message
                borderRadius: BorderRadius.circular(
                    18.0), // Adjust for a smaller oval shape
              ),
              child: Text(
                "I will be back home in few minutes",
                style: TextStyle(
                  fontSize: 14, // Smaller text size
                ),
              ),
            ),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
