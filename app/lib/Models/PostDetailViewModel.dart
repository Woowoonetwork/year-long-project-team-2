import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late String imageUrl; // Add a field for the image URL
  late String profileURL;
  late String postLocation;
  late List<Map<String, String>> imagesWithAltText = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isFavorite = false;

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
    imageUrl = ''; // Set the image URL
    profileURL = 'null';
    postTimestamp = DateTime.now();
    pickupLatLng = LatLng(37.7749, -122.4194);
    tags = ['null'];
  }

  Future<void> fetchData(String postId) async {
    try {
      var documentSnapshot =
          await firestore.collection('post_details').doc(postId).get();

      if (documentSnapshot.exists) {
        var documentData = documentSnapshot.data() as Map<String, dynamic>;
        _updatePostDetails(documentData);
        await _fetchAndUpdateUserDetails(documentData['user_id']);
        await checkIfFavorite(postId);
      }
    } catch (e) {
      print('Error fetching post details: $e');
    }
  }

  Future<void> _fetchAndUpdateUserDetails(String userId) async {
    try {
      var userDocumentSnapshot =
          await firestore.collection('user').doc(userId).get();

      if (userDocumentSnapshot.exists) {
        var userDocumentData =
            userDocumentSnapshot.data() as Map<String, dynamic>;
        _updateUserDetails(userDocumentData);
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> checkIfFavorite(String postId) async {
    String userId = getCurrentUserUID();
    if (userId.isNotEmpty) {
      var userDoc = await firestore.collection('user').doc(userId).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> savedPosts = userData['saved_posts'] ?? [];
        isFavorite = savedPosts.contains(postId);
        notifyListeners();
      }
    }
  }

  void _updatePostDetails(Map<String, dynamic> documentData) {
    allergens = documentData['allergens'] ?? '';
    description = documentData['description'] ?? '';
    title = documentData['title'] ?? '';
    pickupInstructions = documentData['pickup_instructions'] ?? '';
    userid = documentData['user_id'] ?? '';
    rating = documentData['rating'] ?? 0.0;
    pickupLocation = documentData['pickup_location'] ?? '';

    GeoPoint geoPoint = documentData['post_location'] as GeoPoint;
    pickupLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);

    if (documentData.containsKey('images') && documentData['images'] is List) {
      imagesWithAltText = List<Map<String, String>>.from(
        (documentData['images'] as List).map((imageMap) {
          Map<String, dynamic> image = imageMap as Map<String, dynamic>;
          return {
            'url': image['url'] as String? ?? '',
            'alt_text':
                image['alt_text'] as String? ?? '',
          };
        }),
      );
    } else {
      imagesWithAltText =
          []; // This ensures imagesWithAltText is always initialized.
    }

    rating = documentData['rating'] ?? 0.0;
    pickupTime = (documentData['pickup_time'] as Timestamp).toDate();
    expirationDate = (documentData['expiration_date'] as Timestamp).toDate();
    postTimestamp = (documentData['post_timestamp'] as Timestamp).toDate();
    tags = documentData['categories'].split(',');
    notifyListeners();
  }

  void _updateUserDetails(Map<String, dynamic> userDocument) {
    firstName = userDocument['firstName'] ?? '';
    lastName = userDocument['lastName'] ?? '';
    profileURL = userDocument['profileImagePath'] ?? '';
    notifyListeners();
  }

  Future<void> savePost(String postId) async {
    try {
      String userId = getCurrentUserUID();
      if (userId.isNotEmpty) {
        // Add postId to the saved_posts array
        await firestore.collection('user').doc(userId).set({
          'saved_posts': FieldValue.arrayUnion([postId]),
        }, SetOptions(merge: true));

        isFavorite = true;
        notifyListeners();
      } else {
        print('User ID is not available. User might not be logged in.');
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  Future<void> unsavePost(String postId) async {
    try {
      String userId = getCurrentUserUID();
      if (userId.isNotEmpty) {
        // Remove postId from the saved_posts array
        await firestore.collection('user').doc(userId).update({
          'saved_posts': FieldValue.arrayRemove([postId]),
        });

        isFavorite = false;
        notifyListeners();
      } else {
        print("User ID is not available. User might not be logged in.");
      }
    } catch (e) {
      print('Error unsaving post: $e');
    }
  }

  String getCurrentUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 8) {
      return "on " + DateFormat('MMM d').format(dateTime);
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
