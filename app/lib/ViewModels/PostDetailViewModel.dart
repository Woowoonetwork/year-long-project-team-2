import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostDetailViewModel extends ChangeNotifier {
  late String firstName;
  late String lastName;
  late String allergens;
  late String description;
  late DateTime pickupTime;
  late DateTime expirationDate;
  late String pickupLocation;
  late String pickupInstructions;
  late String title;
  late double rating;
  late String userid;
  late DateTime postTimestamp;
  late LatLng pickupLatLng;
  late List<String> tags;

  PostDetailViewModel(String postId) {
    _initializeFields();
    fetchData(postId);
  }

  void _initializeFields() {
    firstName = 'John';
    lastName = 'Doe';
    allergens = 'null';
    description = 'null';
    pickupTime = DateTime.now();
    expirationDate = DateTime.now();
    pickupLocation = 'null';
    pickupInstructions = 'null';
    title = 'null';
    rating = 0.0;
    userid = 'null';
    postTimestamp = DateTime.now();
    pickupLatLng = LatLng(37.7749, -122.4194);
    tags = ['null'];
  }

  Future<void> fetchData(String postId) async {
    try {
      var documentData = await readDocument(
        collectionName: 'post_details',
        docName: postId,
      );
      if (documentData != null) {
        _updatePostDetails(documentData);
      }

      // Assuming userid is set after _updatePostDetails
      var userDocument = await readDocument(
        collectionName: 'user',
        docName: userid,
      );
      if (userDocument != null) {
        _updateUserDetails(userDocument);
      }
    } catch (e) {
      print('Error fetching post details: $e');
    }
    notifyListeners();
  }

  void _updatePostDetails(Map<String, dynamic> documentData) {
    allergens = documentData['allergens'] ?? '';
    description = documentData['description'] ?? '';
    title = documentData['title'] ?? '';
    pickupInstructions = documentData['pickup_instructions'] ?? '';
    userid = documentData['user_id'] ?? '';
    rating = documentData['rating'] ?? 0.0;
    pickupLocation = documentData['pickup_location'] ?? '';
    pickupTime = (documentData['pickup_time'] as Timestamp).toDate();
    expirationDate = (documentData['expiration_date'] as Timestamp).toDate();
    postTimestamp = (documentData['post_timestamp'] as Timestamp).toDate();
    tags = documentData['categories'].split(',');
    notifyListeners();
  }

  void _updateUserDetails(Map<String, dynamic> userDocument) {
    firstName = userDocument['firstName'] ?? '';
    lastName = userDocument['lastName'] ?? '';
    notifyListeners();
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 8) {
      return "on " + DateFormat('MMM d').format(dateTime);
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} day${duration.inDays > 1 ? 'days' : ''} ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 'hrs' : ''} ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 'mins' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
