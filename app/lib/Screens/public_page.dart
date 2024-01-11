import 'package:flutter/cupertino.dart';
import '../firestore_service.dart'; // Adjust the path based on your project structure

class PublicPage extends StatefulWidget {
  @override
  _PublicPageState createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  late String firstName;
  late String lastName;
  late String city;
  late String province;
  double rating = 5.0;
  int itemsSold = 0;
  List<String> reviews = [];

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
      firstName = documentData['firstName'] ?? 'N/A';
      lastName = documentData['lastName'] ?? 'N/A';
      city = documentData['city'] ?? 'N/A';
      province = documentData['province'] ?? 'N/A';
      rating = documentData['rating']?.toDouble() ?? 5.0;

      // Check if 'itemsSold' is an int and handle accordingly
      var itemsSoldData = documentData['itemsSold'];
      if (itemsSoldData is int) {
        itemsSold = itemsSoldData;
      } else {
        itemsSold = 0; // Default or some other logic if not an int
      }

      // Ensure 'reviews' is a list of strings
      if (documentData['reviews'] is List) {
        reviews = List<String>.from(documentData['reviews']);
      } else {
        reviews = []; // Default to empty list if not a list
      }
    });
  }
}

  Widget buildReviewCard(String review) {
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
            buildProfilePlaceholder('${firstName[0]}${lastName[0]}'),
            SizedBox(height: 8),
            buildNameAndLocation(),
            buildRatingAndItemsSold(),
            buildAboutSection(),
            buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget buildProfilePlaceholder(String initials) {
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

  Widget buildNameAndLocation() {
    return Column(
      children: [
        Text(
          '$firstName $lastName',
          textAlign: TextAlign.center,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        Text(
          '$city, $province',
          textAlign: TextAlign.center,
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        ),
      ],
    );
  }

  Widget buildRatingAndItemsSold() {
    return Text(
      '$rating Ratings  $itemsSold items sold',
      textAlign: TextAlign.center,
      style: CupertinoTheme.of(context).textTheme.textStyle,
    );
  }

  Widget buildAboutSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Strawberry sugar high!!! 🍓🍓🍓✨✨✨✨✨',
        style: CupertinoTheme.of(context).textTheme.textStyle,
      ),
    );
  }

  Widget buildReviewsSection() {
    return reviews.isEmpty
        ? Text('No reviews', textAlign: TextAlign.center)
        : Column(
            children: reviews.map((review) => buildReviewCard(review)).toList(),
          );
  }
}
