import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/profileAppBar.dart';
import 'package:FoodHood/Components/colors.dart';

class PublicProfileScreen extends StatefulWidget {
  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  // Example data for the profile, you might want to fetch these from a network or local storage in a real app
  final String postId = "examplePostId";
  final bool isFavorite = false; // Example favorite status
  final String imageUrl = "https://example.com/image.jpg"; // Example image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      body: CustomScrollView(
        slivers: <Widget>[
          ProfileAppBar(
            postId: postId,
            onFavoritePressed: () {
              // Handle favorite button press here
              print("Favorite button pressed");
            },
            isFavorite: isFavorite,
            imageUrl: imageUrl, // Replace with an actual image URL or asset
          ),
          SliverFillRemaining(
            child: Center(
              child: Text("Public Profile Content Goes Here"),
              // Build the rest of your profile screen content here
            ),
          ),
        ],
      ),
    );
  }
}
