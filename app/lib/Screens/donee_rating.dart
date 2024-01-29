import 'package:FoodHood/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoneeRatingPage extends StatefulWidget {
  final String postId;
  const DoneeRatingPage({Key? key, required this.postId}) : super(key: key);
  @override
  _DoneeRatingPageState createState() => _DoneeRatingPageState();
}

class _DoneeRatingPageState extends State<DoneeRatingPage> {
  String? reservedByName;
  int _rating = 0; // State variable to keep track of the rating
  TextEditingController _commentController =
      TextEditingController(); // Initialize the text controller

  @override
  void initState() {
    super.initState();
    fetchReservedByName();
    // Fetch reserved by user name when the widget initializes
  }

  Future<void> _storeCommentInDatabase() async {
    String comment = _commentController.text;
    int starRating = _rating; // Number of stars clicked

    DocumentReference postDocRef = FirebaseFirestore.instance
        .collection('post_details')
        .doc(widget.postId);

    try {
      DocumentSnapshot postDoc = await postDocRef.get();

      if (postDoc.exists && postDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
        String userId = postData['reserved_by'];

        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('user').doc(userId);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          List<dynamic> comments = List.from(userData['comments'] ?? []);
          List<dynamic> ratings = List.from(userData['ratings'] ?? []);

          comments.add(comment);
          ratings.add(starRating);

          // Calculate the average rating
          double avgRating = 0;
          if (ratings.isNotEmpty) {
            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
            // Format the average to two decimal places
            avgRating = double.parse(avgRating.toStringAsFixed(2));
          }

          await userDocRef.update({
            'comments': comments,
            'ratings': ratings,
            'avgRating': avgRating
          });
          print("Stored in database");
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          print("User document not found for ID: $userId");
        }
      } else {
        print("Post details document not found for ID: ${widget.postId}");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<void> fetchReservedByName() async {
    final CollectionReference postDetailsCollection =
        FirebaseFirestore.instance.collection('post_details');

    // Retrieve the reserved_by user ID from your current data
    final String postId = widget.postId;
    try {
      // Fetch the post details document
      final DocumentSnapshot postSnapshot =
          await postDetailsCollection.doc(postId).get();

      if (postSnapshot.exists) {
        // Extract the reserved_by user ID from the post details
        final String reservedByUserId = postSnapshot['reserved_by'];

        // Fetch the user document using reserved_by user ID
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(reservedByUserId)
            .get();

        if (userSnapshot.exists) {
          // Extract the user name from the user document
          final userName = userSnapshot[
              'firstName']; // Assuming 'name' is the field storing the user's name
          setState(() {
            reservedByName =
                userName; // Update the reserved by user name in the UI
          });
        } else {
          print(
              'User document does not exist for reserved by user ID: $reservedByUserId');
        }
      } else {
        print('Post details document does not exist for ID: $postId');
      }
    } catch (error) {
      print('Error fetching reserved by user name: $error');
    }
  }

  void dispose() {
    _commentController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  bool get _isPublishButtonEnabled {
    return _rating > 0 && _commentController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('', style: TextStyle(letterSpacing: -1.34)),
            border: Border(bottom: BorderSide.none),
            backgroundColor: groupedBackgroundColor,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: 22, color: CupertinoColors.label.resolveFrom(context)),
            ),
            trailing: GestureDetector(
              onTap: () {
                print("Message Harry Tapped");
              },
              child: Text(
                'Message ${reservedByName ?? 'Unknown User'}',
                style:
                    TextStyle(color: CupertinoColors.activeBlue, fontSize: 17),
              ),
            ),
          ),
          // ... [Your existing code for the navigation bar] ...
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  child: Text(
                    "How was your experience with ${reservedByName ?? 'Unknown User'}?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/images/sampleProfile.png'), // Replace with your image asset or network image
                  radius: 40, // Adjust the radius as needed
                  backgroundColor: CupertinoColors.systemGrey4,
                  // If you want to add a border
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        _rating > index ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      iconSize: 40,
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16), // Padding for the text field
                  child: CupertinoTextField(
                    controller: _commentController,
                    onChanged: (_) => setState(() {}),
                    maxLines:
                        3, // Increased maxLines to make the text field taller
                    placeholder: 'Write your comments here',
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(
                        color: CupertinoColors.systemGrey3,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.all(12), // Internal padding for text content
                  ),
                ),
                SizedBox(height: 40),

                CupertinoButton(
                  onPressed: _isPublishButtonEnabled
                      ? () async {
                          await _storeCommentInDatabase();
                        }
                      : null,
                  color: _isPublishButtonEnabled
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.quaternarySystemFill,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.publish, size: 20),
                      SizedBox(width: 4),
                      Text("Publish"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // ... [Any other widgets] ...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
