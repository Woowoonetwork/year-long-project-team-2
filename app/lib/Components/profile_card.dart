import 'package:FoodHood/Screens/public_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCard extends StatefulWidget {
  ProfileCard({Key? key}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  // Default values
  String firstName = 'No first name';
  String lastName = 'No last name';
  String city = 'No city';
  String province = 'No province';
  String photo = 'assets/images/sampleProfile.png';
  String email = 'No email';
  double rating = 0.0;
  int itemsSold = 0;
  List<String> reviews = [];
  bool isLoading = true;

  // Reference to Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    setUpStreamListener();
  }

  void setUpStreamListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      firestore.collection('user').doc(user.uid).snapshots().listen((snapshot) {
        if (mounted) {
          // Check if the widget is still in the widget tree
          if (snapshot.exists) {
            updateProfileData(snapshot.data()!);
          } else {
            setState(() => isLoading = false);
          }
        }
      }, onError: (e) {
        if (mounted) {
          // Check if the widget is still in the widget tree
          print('Error listening to user data changes: $e');
          setState(() => isLoading = false);
        }
      });
    } else {
      if (mounted) {
        // Check if the widget is still in the widget tree
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateProfileData(Map<String, dynamic> documentData) {
    if (mounted) {
      // Check if the widget is still in the widget tree
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = '$firstName $lastName';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => PublicPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.tertiarySystemBackground, context),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
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
                  SizedBox(width: 16), // For spacing between image and text
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
                            letterSpacing: -1.3,
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
    );
  }
}
