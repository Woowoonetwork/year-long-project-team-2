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
        title: Row(
          children: <Widget>[
            Text(
              'Harry Styles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust color as needed
              ),
            ),
            SizedBox(width: 8), // Space between text and status circle
            // Small circle with green fill
            Container(
              width: 10, // Adjust size as needed
              height: 10, // Adjust size as needed
              decoration: BoxDecoration(
                color: Colors.green, // Green fill
                shape: BoxShape.circle, // Circular shape
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last seen a minute ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false, // Aligns the title to the start
      ),
      body: Center(
        child: Text('Message Screen Page'),
      ),
    );
  }
}
