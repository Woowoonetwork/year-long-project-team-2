import 'package:flutter/cupertino.dart';
import '../firestore_service.dart'; // Adjust the path based on your project structure
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  // Initial variables with default values
  String firstName = 'No first name'; // Changed from 'Loading...'
  String lastName = 'No last name'; // Changed from 'Loading...'
  String city = 'No city'; // Changed from 'Loading...'
  String province = 'No province'; // Changed from 'Loading...'
  String photo = 'assets/images/sampleProfile.png'; // Default image path
  String email = 'No email'; // Changed from 'Loading...'
  double rating = 0.0;
  int itemsSold = 0;
  List<String> reviews = [];
  bool isLoading = true; // To keep track of the loading state

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false; // Update the loading state
      });
      return;
    }
    final userUID = user.uid;
    try {
      Map<String, dynamic>? documentData = await readDocument(
        collectionName: 'user',
        docName: userUID,
      );

      if (documentData != null) {
        setState(() {
          firstName = documentData['firstName'] ?? 'No first name';
          lastName = documentData['lastName'] ?? 'No last name';
          city = documentData['city'] ?? 'No city';
          province = documentData['province'] ?? 'No province';
          email = documentData['email'] ?? 'No email';
          photo = documentData['photo'] ?? 'assets/images/sampleProfile.png';
          rating = documentData['rating']?.toDouble() ?? 0.0;
          reviews = List<String>.from(documentData['reviews'] ?? []);
          itemsSold = reviews.length;
          isLoading = false; // Update the loading state
        });
      } else {
        setState(() {
          isLoading = false; // Update the loading state
        });
      }
    } catch (e) {
      // Handle any exceptions here
      print('An error occurred while fetching user data: $e');
      setState(() {
        isLoading = false; // Update the loading state even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName;
    if (firstName == 'Loading...' && lastName == 'Loading...') {
      fullName = 'Loading...';
    } else {
      fullName = '$firstName $lastName';
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemBackground, context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withAlpha(20),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child:
              // If isLoading is true, show the activity indicator
              // Otherwise, show the profile information
              isLoading
                  ? Center(
                      child:
                          CupertinoActivityIndicator()) // Show loading indicator when data is being fetched
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: photo.startsWith('http')
                              ? Image.network(
                                  photo,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  photo,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(
                            width: 16), // For spacing between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: TextStyle(
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.label, context),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                email,
                                style: TextStyle(
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.label, context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '$city, $province',
                                style: TextStyle(
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.label, context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}
