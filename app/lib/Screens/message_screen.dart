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
    // This is a placeholder Scaffold widget. Replace it with your actual UI.
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Screen'),
      ),
      body: Center(
        child: Text('Message Screen Page'),
      ),
    );
  }
}
