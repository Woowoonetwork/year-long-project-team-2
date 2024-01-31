import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Screens/public_page.dart';

class ProfileCard extends StatefulWidget {
  ProfileCard({Key? key}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String? firstName;
  String? lastName;
  String? city;
  String? province;
  String photo = 'assets/images/sampleProfile.png';
  String? email;
  double? rating;
  List<String>? reviews;
  bool isLoading = true;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    setUpStreamListener();
  }

  void setUpStreamListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      firestore.collection('user').doc(user.uid).snapshots().listen(
        (snapshot) {
          if (mounted && snapshot.exists) {
            updateProfileData(snapshot.data()!);
          } else {
            setState(() => isLoading = false);
          }
        },
        onError: (e) {
          if (mounted) {
            print('Error listening to user data changes: $e');
            setState(() => isLoading = false);
          }
        },
      );
    } else {
      setState(() => isLoading = false);
    }
  }

  void updateProfileData(Map<String, dynamic> documentData) {
    if (mounted) {
      setState(() {
        firstName = documentData['firstName'];
        lastName = documentData['lastName'];
        city = documentData['city'];
        province = documentData['province'];
        email = documentData['email'];
        photo = documentData['profileImagePath'];
        rating = documentData['rating']?.toDouble();
        reviews = List<String>.from(documentData['reviews'] ?? []);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : buildProfileContent(context),
      ),
    );
  }

  Widget buildProfileContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipOval(child: profileImage()),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: profileDetails(context),
          ),
        ),
      ],
    );
  }

  Widget profileImage() {
    if (photo.isNotEmpty) {
      // Check if the photo string is a URL (starts with 'http' or 'https')
      if (Uri.parse(photo).isAbsolute) {
        return Image.network(photo, width: 70, height: 70, fit: BoxFit.cover);
      } else {
        // Assuming the photo is a local asset if not a URL
        return Image.asset(photo, width: 70, height: 70, fit: BoxFit.cover);
      }
    }
    // Fallback to a default asset image if the photo string is empty
    return Image.asset('assets/images/sampleProfile.png',
        width: 70, height: 70, fit: BoxFit.cover);
  }

  List<Widget> profileDetails(BuildContext context) {
    List<Widget> details = [];

    // Conditional addition of name
    String? fullName =
        [firstName, lastName].where((part) => part != null).join(' ');
    if (fullName.isNotEmpty) {
      details.add(buildProfileText(fullName, 24, FontWeight.w600));
      details.add(SizedBox(height: 2));
    } else {
      details.add(buildProfileText('FoodHood User', 24, FontWeight.w600));
      details.add(SizedBox(height: 2));
    }

    // Conditional addition of email
    if (email != null && email!.isNotEmpty) {
      details.add(buildDescriptiveText(email!, 12, FontWeight.w500));
      details.add(SizedBox(height: 2));
    }

    // Conditional addition of location
    String? location =
        [city, province].where((part) => part != null).join(', ');
    if (location.isNotEmpty) {
      details.add(buildDescriptiveText(location, 12, FontWeight.w500));
    }

    return details;
  }

  Widget buildProfileText(String text, double fontSize, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
        color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -1.3,
      ),
    );
  }

  Widget buildDescriptiveText(
      String text, double fontSize, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel, context),
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
