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
        padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(
                "I will be back home in a few minutes",
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 8), // Adds space between the messages
            Container(
              margin: EdgeInsets.only(left: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(
                "Is 8:45 okay for you?",
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 8), // Adds space between the messages
            Container(
              margin: EdgeInsets.only(left: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(
                "I will be back home in a few minutes",
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 20.0), // Aligns with the messages
              child: Text(
                "8:24, seen",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5), // Faded text
                ),
              ),
            ),
            // Add more widgets as needed

            SizedBox(height: 20),
            // Sent message 1
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Bluish color for the sent message
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    "Blah Blah Blah Blah",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white), // White text
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Sent message 2
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Bluish color for the sent message
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    "I will be back home in a few minutes",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white), // White text
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Sent message 3
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Bluish color for the sent message
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    "I will be back home in a few minutes",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white), // White text
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Sent message 3
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue, // Bluish color for the sent message
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    "Are you at the place right now?",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white), // White text
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: 15.0), // Aligns 15 units from the right
                  child: Text(
                    "8:48, received",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5), // Faded black text
                    ),
                  ),
                ),
              ],
            ),

            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
