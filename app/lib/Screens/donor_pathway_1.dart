//donor_pathway_1.dart

import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const double _iconSize = 22.0;
const double _defaultHeadingFontSize = 34.0;
const double _defaultFontSize = 16.0;

class DonorScreen extends StatefulWidget {
  final String postId;
  const DonorScreen({Key? key, required this.postId}) : super(key: key);
  //const DonorScreen({Key? key}) : super(key: key);

  @override
  _DonorScreenState createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {

  String? reservedByName; // Variable to store the reserved by user name
  String? reservedByLastName;
  String pickupLocation = '';

  @override
  void initState() {
    super.initState();
    fetchReservedByName(); // Fetch reserved by user name when the widget initializes
    //fetchPickupLocation();
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
        pickupLocation = postSnapshot['pickup_location'];

        // Fetch the user document using reserved_by user ID
        final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(reservedByUserId)
            .get();

        if (userSnapshot.exists) {
          // Extract the user name from the user document
          final userName = userSnapshot['firstName']; 
          final userLastName = userSnapshot['lastName'];
          setState(() {
            reservedByName = userName; // Update the reserved by user name in the UI
            reservedByLastName = userLastName;
          });
        } else {
          print('User document does not exist for reserved by user ID: $reservedByUserId');
        }
      } else {
        print('Post details document does not exist for ID: $postId');
      }
    } catch (error) {
      print('Error fetching reserved by user name: $error');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            FeatherIcons.x,
            size: _iconSize,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            "Message ${reservedByName ?? 'Unknown User'}",
            style: TextStyle(
              color: Color(0xFF337586), // Your custom color
            ),
          ),
          onPressed: () {
            // Close the current screen
            Navigator.of(context).pop();
          },
        ),
        border: Border(bottom: BorderSide.none),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          // Your sliver widgets go here
          __buildHeadingTextField(text: "Your order has been reserved by ${reservedByName ?? 'Unknown User'}"),
          SliverToBoxAdapter(
            child: SizedBox(height: 16.0),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:20.0),
              child: Center (
                child: OrderInfoSection(
                  avatarUrl: '', 
                  reservedByName: reservedByName, 
                  reservedByLastName: reservedByLastName,
                ),
              )
            )        
          ),
          __buildTextField(text: "Pickup at $pickupLocation"),
          __buildButton(text: "Confirm"),
        ],
      ),
    );
  }

  // Reusable widget to build the text fields
  Widget __buildHeadingTextField({
    required String text,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _defaultHeadingFontSize,
          ),
        ),
      ),
    );
  }

  Widget __buildTextField({
    required String text,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
            width: 1.0, 
          ),
          color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(16.0), 
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _defaultFontSize,
          ),
        ),
      ),
      ),
    );
  }

  Widget __buildButton({
  required String text,
}) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.quaternarySystemFill.resolveFrom(context), 
            width: 2.0, 
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1), // Shadow color and opacity
              spreadRadius: 1, // Spread radius
              blurRadius: 2, // Blur radius
              offset: Offset(0, 2), // Shadow offset
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            text,
            style: TextStyle(
              fontSize: _defaultFontSize,
              color: CupertinoColors.label, 
            ),
          ),
          color: CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(16.0),
          onPressed: () {
            // Do something
          },
        ),
      ),
    ),
  );
}

}

class OrderInfoSection extends StatelessWidget {
  final String avatarUrl;
  final String? reservedByName;
  final String? reservedByLastName;

  const OrderInfoSection({
    Key? key,
    required this.avatarUrl,
    required this.reservedByName,
    required this.reservedByLastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a default image if avatarUrl is empty or null
    String effectiveAvatarUrl =
        avatarUrl.isEmpty ? 'assets/images/sampleProfile.png' : avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                AssetImage(effectiveAvatarUrl), // Load the image from assets
            radius: 9, // Optional: Adjust the radius to fit your design
          ),
          SizedBox(width: 8),
          Text(
            'Reserved by $reservedByName $reservedByLastName',
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
