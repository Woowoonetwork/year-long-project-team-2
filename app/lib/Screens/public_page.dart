import 'package:flutter/cupertino.dart';
import '../firestore_service.dart'; // Adjust the path based on your project structure

class PublicPage extends StatefulWidget {
  @override
  _PublicPageState createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  UserProfile userProfile = UserProfile.empty();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var documentData = await readDocument(
      collectionName: 'user',
      docName: 'afkwlDWxekVhdgV1YPZFK7E34UH3',
    );

    if (documentData != null) {
      setState(() {
        userProfile = UserProfile.fromMap(documentData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Public Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Block'),
          onPressed: () {
            // Implement block functionality here
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: 16),
            ProfilePlaceholder(initials: userProfile.initials),
            SizedBox(height: 8),
            NameAndLocation(userProfile: userProfile),
            RatingAndItemsSold(userProfile: userProfile),
            AboutSection(),
            ReviewsSection(reviews: userProfile.reviews),
          ],
        ),
      ),
    );
  }
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String city;
  final String province;
  final double rating;
  final int itemsSold;
  final List<String> reviews;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.province,
    required this.rating,
    required this.itemsSold,
    required this.reviews,
  });

  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      firstName: data['firstName'] ?? 'N/A',
      lastName: data['lastName'] ?? 'N/A',
      city: data['city'] ?? 'N/A',
      province: data['province'] ?? 'N/A',
      rating: data['rating']?.toDouble() ?? 5.0,
      itemsSold: data['itemsSold'] is int ? data['itemsSold'] : 0,
      reviews: data['reviews'] is List ? List<String>.from(data['reviews']) : [],
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      firstName: 'N/A',
      lastName: 'N/A',
      city: 'N/A',
      province: 'N/A',
      rating: 5.0,
      itemsSold: 0,
      reviews: [],
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  final String initials;

  const ProfilePlaceholder({Key? key, required this.initials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4,
        borderRadius: BorderRadius.circular(36),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 32,
          color: CupertinoColors.white,
        ),
      ),
    );
  }
}

class NameAndLocation extends StatelessWidget {
  final UserProfile userProfile;

  const NameAndLocation({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${userProfile.firstName} ${userProfile.lastName}',
          textAlign: TextAlign.center,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        Text(
          '${userProfile.city}, ${userProfile.province}',
          textAlign: TextAlign.center,
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        ),
      ],
    );
  }
}

class RatingAndItemsSold extends StatelessWidget {
  final UserProfile userProfile;

  const RatingAndItemsSold({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${userProfile.rating} Ratings  ${userProfile.itemsSold} items sold',
      textAlign: TextAlign.center,
      style: CupertinoTheme.of(context).textTheme.textStyle,
    );
  }
}

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'About the user...',
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
    );
  }
}

class ReviewsSection extends StatelessWidget {
  final List<String> reviews;

  const ReviewsSection({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(child: Text('No reviews', textAlign: TextAlign.center));
    } else {
      return Column(
        children: reviews.map((review) => ReviewCard(review: review)).toList(),
      );
    }
  }
}

class ReviewCard extends StatelessWidget {
  final String review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        review,
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
    );
  }
}
