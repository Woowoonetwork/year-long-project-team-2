//donor_screen.dart

import 'package:FoodHood/Screens/message_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Screens/donee_rating.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double _iconSize = 22.0;
const double _defaultHeadingFontSize = 32.0;
const double _defaultFontSize = 16.0;
const double _defaultOrderInfoFontSize = 12.0;

// Define enum to represent different states
enum OrderState { reserved, confirmed, delivering, readyToPickUp }

class DonorScreen extends StatefulWidget {
  final String postId;
  const DonorScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _DonorScreenState createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  String? reservedByName; // Variable to store the reserved by user name
  String? reservedByLastName;
  String pickupLocation = '';
  //bool isConfirmed = false;
  OrderState orderState = OrderState.reserved;
  late double _textScaleFactor;
  late double adjustedFontSize;
  late double adjustedHeadingFontSize;
  late double adjustedOrderInfoFontSize;
  late LatLng pickupLatLng;

  @override
  void initState() {
    super.initState();
    pickupLatLng = LatLng(49.8862, -119.4971); // Initialize the coordinates to downtown Kelowna
    fetchPostInformation(); // Fetch reserved by user name when the widget initializes
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();   
  }

  Future<void> fetchPostInformation() async {
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
        
        if (postSnapshot['post_location'] is GeoPoint) {
          GeoPoint geoPoint = postSnapshot['post_location'] as GeoPoint;
          //pickupLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);
          setState(() {
            pickupLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);
          });
        } else {
          // Provide a default location
          setState(() {
            pickupLatLng = LatLng(49.8862, -119.4971); 
          }); 
        }
        print(pickupLatLng);

        setState(() {});

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
            reservedByName =
                userName; // Update the reserved by user name in the UI
            reservedByLastName = userLastName;
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

  void _updateAdjustedFontSize() {
    adjustedFontSize = _defaultFontSize * _textScaleFactor;
    adjustedHeadingFontSize = _defaultHeadingFontSize * _textScaleFactor;
    adjustedOrderInfoFontSize = _defaultOrderInfoFontSize * _textScaleFactor;
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
        trailing: reservedByName != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  "Message ${reservedByName ?? 'Unknown User'}",
                  style: TextStyle(
                    color: accentColor,
                  ),
                ),
                onPressed: () {
                  // Close the current screen
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) =>
                            MessageScreenPage()
                    ), 
                  );
                },
              )
            : null,
        border: Border(bottom: BorderSide.none),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          __buildHeadingTextField(
            text: _buildHeadingText(),
          ),
          SizedBox(height: 16.0),

          //Only show the order info section if the order has been reserved.
          if (reservedByName != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: OrderInfoSection(
                  avatarUrl: '',
                  reservedByName: reservedByName,
                  reservedByLastName: reservedByLastName,
                  adjustedOrderInfoFontSize: adjustedOrderInfoFontSize,
                ),
              ),
            ),
          
          __buildTextField(text: "Pickup at specified location"),
          //print(pickupLatLng),
           _buildMap(context),
           __buildButton(),

        ],
      ),
    );
  }

  // Reusable widget to build the text fields
  Widget __buildHeadingTextField({
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: adjustedHeadingFontSize,
        ),
      ),
    );
  }

  // Method to build heading text based on order state
  String _buildHeadingText() {
    if (reservedByName == null) {
      return "Your order has not been reserved yet";
    }

    switch (orderState) {
      case OrderState.reserved:
        return "Your order has been reserved by ${reservedByName ?? 'Unknown User'}";
      case OrderState.confirmed:
        return "Your order has been confirmed for ${reservedByName ?? 'Unknown User'}";
      case OrderState.delivering:
        return "Your order is out for delivery for ${reservedByName ?? 'Unknown User'}";
      case OrderState.readyToPickUp:
        return "Your order for ${reservedByName ?? 'Unknown User'} is ready to pick up";
    }
  }

  Widget _buildMap(BuildContext context) {
    final LatLng? locationCoordinates = pickupLatLng;

    if (locationCoordinates != null) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: 250.0,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationCoordinates,
              zoom: 12.0,
            ),
            markers: Set.from([
              Marker(
                markerId: MarkerId('pickupLocation'),
                position: locationCoordinates,
              ),
            ]),
            zoomControlsEnabled: false,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            myLocationEnabled: false,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 250.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          color: CupertinoColors.systemGrey4,
        ),
        alignment: Alignment.center,
        child: Text('Map Placeholder'),
      );
    }
  }

  Widget __buildTextField({
    required String text,
  }) {
    return Padding(
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
            fontSize: adjustedFontSize,
          ),
        ),
      ),
    );
  }

  Widget __buildButton() {
    if (reservedByName == null) {
      // Return an empty container if the order hasn't been reserved yet
      return Padding(
        padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
        child: Container(),
      );
    }

    if (orderState == OrderState.readyToPickUp) {
      return Padding(
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
                color: CupertinoColors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,            
            color: CupertinoColors.tertiarySystemBackground,
            borderRadius: BorderRadius.circular(16.0),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => DoneeRatingPage(
                    postId: widget.postId,
                  ),
                ),
              );
            },
            child: Text(
              "Leave a Review",
              style: TextStyle(
                fontSize: adjustedFontSize,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ),
      );
    } else {
      String buttonText = _buildButtonText();
      return Padding(
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
                color: CupertinoColors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: CupertinoColors.tertiarySystemBackground,
            borderRadius: BorderRadius.circular(16.0),
            onPressed: () {
              setState(() {
                orderState = _getNextOrderState();
              });
            },
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: adjustedFontSize,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ),
      );
    }
  }

  String _buildButtonText() {
    switch (orderState) {
      case OrderState.reserved:
        return "Confirm";
      case OrderState.confirmed:
        return "Delivering";
      case OrderState.delivering:
        return "Ready to Pick Up";
      case OrderState.readyToPickUp:
        return "Confirm";
    }
  }

  OrderState _getNextOrderState() {
    switch (orderState) {
      case OrderState.reserved:
        return OrderState.confirmed;
      case OrderState.confirmed:
        return OrderState.delivering;
      case OrderState.delivering:
        return OrderState.readyToPickUp;
      case OrderState.readyToPickUp:
        return OrderState.reserved;
    }
  }

  
}

class OrderInfoSection extends StatelessWidget {
  final String avatarUrl;
  final String? reservedByName;
  final String? reservedByLastName;
  final double adjustedOrderInfoFontSize;

  const OrderInfoSection({
    Key? key,
    required this.avatarUrl,
    required this.reservedByName,
    required this.reservedByLastName,
    required this.adjustedOrderInfoFontSize,
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
            radius: 9,
          ),
          SizedBox(width: 8),
          Text(
            'Reserved by $reservedByName $reservedByLastName',
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontSize: adjustedOrderInfoFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
