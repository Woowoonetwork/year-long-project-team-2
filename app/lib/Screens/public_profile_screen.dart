import 'package:FoodHood/Components/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profileAppBar.dart';
import 'package:FoodHood/Components/colors.dart';

class PublicProfileScreen extends StatefulWidget {
  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final String postId = "examplePostId";
  final bool isFavorite = false;
  final String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      body: CustomScrollView(
        slivers: <Widget>[
          ProfileAppBar(
            postId: postId,
            onBlockPressed: () {
              // Block user here
            },
            isCurrentUser: false,
            isBlocked: isFavorite,
            imageUrl: imageUrl,
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: true,
              top: false,
              child: Column(
                children: <Widget>[
                  AboutSection(),
                  RecentPostSection(),
                  ReviewSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ReviewSection
class ReviewSection extends StatelessWidget {
  // Example reviews data
  final List<Map<String, dynamic>> reviews = [
    {'text': 'Harry is so nice! He kept the food protected in pouring rain!!'},
    {'text': 'I had a great experience with harry, and would recommend him!'},
    {'text': 'The food was great, and Harry is a sweetheart.'},
    {'text': 'Would recommend!'},
    {'text': 'Harry is the best!'},
    {'text': 'I love Harry!'},
    {'text': 'Harry is so nice! He kept the food protected in pouring rain!!'},
    {'text': 'I had a great experience with harry, and would recommend him!'},
    {'text': 'The food was great, and Harry is a sweetheart.'},
    {'text': 'Would recommend!'},
    {'text': 'Harry is the best!'},
    {'text': 'I love Harry!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, bottom: 16),
          child: Text(
            'Reviews',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.70,
            ),
          ),
        ),
        Column(
          children: reviews
              .map((review) => ReviewItem(review: review['text']))
              .toList(),
        ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'About Harry',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.70,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                CupertinoColors.tertiarySystemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Strawberry sugar high!!!',
              style: TextStyle(
                color:
                    CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String review;

  const ReviewItem({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            // Replace with your actual asset or network image
            backgroundImage: AssetImage('assets/images/sampleProfile.png'),
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            // Wrap the Container in an Expanded widget to take up remaining space
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color:
                    CupertinoColors.quaternarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review,
                style: TextStyle(
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentPostSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 16),
          child: Text(
            'Recent Posts',
            style: TextStyle(
              color:
                  CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.70,
            ),
          ),
        ),
        Container(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Container(                
                width: 300,
                height: 150,
                margin: EdgeInsets.only(left: 4.0, top: 24, bottom: 24.0),
                child: PostCard(
                  imageLocation: 'assets/images/sampleFood.jpg',
                  title: 'Strawberry Sugar High',
                  tags: ['Dessert', 'Strawberry', 'Sweet'],
                  tagColors: [
                    CupertinoColors.systemRed,
                    CupertinoColors.systemGreen,
                    CupertinoColors.systemYellow,
                  ],
                  firstname: 'Harry',
                  lastname: 'Potter',
                  timeAgo: '2 hours ago',
                  onTap: (postid) {
                    print('Post tapped');
                  },
                  showShadow: true,
                  imageHeight: 60,
                  postId: 'examplePostId',
                  profileURL: 'assets/images/sampleProfile.png',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
