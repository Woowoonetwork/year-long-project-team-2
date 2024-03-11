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
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:FoodHood/Components/PendingConfirmationWithTimer.dart';
import 'package:timelines/timelines.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';

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
  double rating = 0.0;
  String pickupLocation = '';
  String photo = '';
  String? reservedByUserId = '';
  OrderState orderState = OrderState.reserved;
  late double _textScaleFactor;
  late double adjustedFontSize;
  late double adjustedHeadingFontSize;
  late double adjustedOrderInfoFontSize;
  late LatLng pickupLatLng;
  late PostDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    pickupLatLng = LatLng(49.8862, -119.4971); // Initialize the coordinates to downtown Kelowna
    fetchPostInformation(); // Fetch reserved by user name when the widget initializes
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
  }

  // Reading post information
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
        reservedByUserId = postSnapshot['reserved_by'];
        //pickupLocation = postSnapshot['pickup_location'];

        if (postSnapshot['post_location'] is GeoPoint) {
          GeoPoint geoPoint = postSnapshot['post_location'] as GeoPoint;
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

        // Fetch the user document using reserved_by user ID if it exists
        if (reservedByUserId != null) {
          final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('user')
              .doc(reservedByUserId)
              .get();

          if (userSnapshot.exists) {
            // Extract the user name from the user document
            final userName = userSnapshot['firstName'];
            final userLastName = userSnapshot['lastName'];
            final userRating = userSnapshot['avgRating'];

            setState(() {
              reservedByName = userName; 
              reservedByLastName = userLastName;
              rating = userRating;
              photo = userSnapshot['profileImagePath'] as String? ?? '';
            });
          } else {
            print(
                'User document does not exist for reserved by user ID: $reservedByUserId');
          }
        }

        // Extract post_status and set orderState accordingly
        final String postStatus = postSnapshot['post_status'];
        setState(() {
          switch (postStatus) {
            case 'pending':
              orderState = OrderState.reserved;
              break;
            case 'confirmed':
              orderState = OrderState.confirmed;
              break;
            case 'delivering':
              orderState = OrderState.delivering;
              break;
            case 'readyToPickUp':
              orderState = OrderState.readyToPickUp;
              break;
          }
        });
      } else {
        // Handle the case where the post details document doesn't exist
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
    return CupertinoPageScaffold(
      backgroundColor: detailsBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: detailsBackgroundColor,
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
                child: Text("Message ${reservedByName ?? 'Unknown User'}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: accentColor)),
                onPressed: () {
                  // Close the current screen
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => MessageScreenPage()),
                  );
                },
              )
            : null,
        border: null,
      ),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  __buildHeadingTextField(text: _buildHeadingText()),
                  SizedBox(height: 16.0),
                  //Only show the order info section if the order has been reserved.
                  if (reservedByName != null)
                    OrderInfoSection(
                      reservedByName: reservedByName,
                      reservedByLastName: reservedByLastName,
                      adjustedOrderInfoFontSize: adjustedOrderInfoFontSize,
                      rating: rating,
                      photo: photo,
                    ),
                    
                  SizedBox(height: 10.0),

                  // Progress Bar 
                  _buildProgressBar(),

                  // SizedBox(height: 25,),

                  //__buildTextField(text: "Pickup at ."),
                  _buildMap(context),
                  
                  // PendingConfirmationWithTimer(
                  //       durationInSeconds: 120, postId: widget.postId),
                
                  // Replace the placeholder with the chat bubble in the future
                  //SizedBox(height: 200.0),

                ],
              ),

              if (reservedByName != null)
                _buildButtonAndCancelButtonRow(), // Call the new method here
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widget to build the Progress Bar
  Widget _buildProgressBar(){
    return Container(
      height: 120,
      alignment: Alignment.topCenter, 
      child: Timeline.tileBuilder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(space: 6.0, thickness: 3.0),
          nodePosition: 0
        ),

        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemCount: 4,

          itemExtentBuilder: (_, __) {
            final double padding = 16.0;
            final double availableWidth = MediaQuery.of(context).size.width - padding * 2;
            return availableWidth / 4.0; 
          },

          oppositeContentsBuilder: (context, index) {
            return Container();
          },
          
          contentsBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildProgressPoint("Reserved", OrderState.reserved);
              case 1:
                return _buildProgressPoint("Confirmed", OrderState.confirmed);
              case 2:
                return _buildProgressPoint("Delivering", OrderState.delivering);
              case 3:
                return _buildProgressPoint("Ready to Pick Up", OrderState.readyToPickUp);
              default:
                return Container();
            }
          },

          indicatorBuilder: (_, index) {
            if (reservedByName == null){
              return OutlinedDotIndicator(
                borderWidth: 2.0,
                color: accentColor,
              );
            }
            if (index < (_calculateProgress() * 4).toInt()) {
              return DotIndicator(
                color: accentColor,
              );
            } else {
              return OutlinedDotIndicator(
                borderWidth: 2.0,
                color:  accentColor,
              );
            }
          },

          connectorBuilder: (_, index, type) {
            if (index < (_calculateProgress() * 4).toInt()) {
              return SolidLineConnector(
                color: accentColor,
              );
            } else {
              return DashedLineConnector(
                color:  accentColor,
              );
            }
          },
        ),
      ),
    );
  }

  // Widget to build each progress point
  Widget _buildProgressPoint(String text, OrderState state) {
    final bool isReserved = reservedByName != null;
    final bool isCurrentState = orderState == state;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: adjustedFontSize - 2.0,
          fontWeight: FontWeight.bold,
          color: isReserved
              ? isCurrentState
                  ? CupertinoDynamicColor.resolve(
                      CupertinoColors.label, context)
                  : CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context)
              :
                  CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context)
        ),
      ),
    );
  }


  // Method to calculate progress based on order state
  double _calculateProgress() {
    switch (orderState) {
      case OrderState.reserved:
        return 0.25; // Progress for reserved state
      case OrderState.confirmed:
        return 0.5; // Progress for confirmed state
      case OrderState.delivering:
        return 0.75; // Progress for delivering state
      case OrderState.readyToPickUp:
        return 1.0; // Progress for readyToPickUp state
      default:
        return 0.0; // Default progress
    }
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
          fontWeight: FontWeight.w600,
          letterSpacing: -1.0,
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
      // case OrderState.notReserved:
      //   return "Your order has not been reserved yet";
      case OrderState.reserved:
        return "Your order has been reserved by ${reservedByName ?? 'Unknown User'}";
      case OrderState.confirmed:
        return "Your order has been confirmed for ${reservedByName ?? 'Unknown User'}";
      case OrderState.delivering:
        return "Your order is out for delivery for ${reservedByName ?? 'Unknown User'}";
      case OrderState.readyToPickUp:
        return "Your order for ${reservedByName ?? 'Unknown User'} is ready to pick up";
      default:
        return "Your order has not been reserved yet";
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

  Widget _buildMap(BuildContext context) {
    final LatLng? locationCoordinates = pickupLatLng;

    if (locationCoordinates != null) {
      return  ClipRRect(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(16), bottom: Radius.circular(15)),
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

  Widget _buildButton() {
    if (orderState == OrderState.readyToPickUp) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              //spreadRadius: 1,
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(100.0),
          color: CupertinoColors.tertiarySystemBackground,
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
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
            ),
          ),
        ),
      );
    } else {
      String buttonText = _buildButtonText();
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              //spreadRadius: 1,
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(100.0),
          onPressed: () {
            setState(() {
              _handlePostStatus();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.check,
                color: CupertinoColors.systemGreen,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                buttonText,
                style: TextStyle(
                    fontSize: adjustedFontSize,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.label, context),
                    fontWeight: FontWeight.w500),
              ),
            ],
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
      default:
        return "Confirm";
      //case OrderState.readyToPickUp:
      //return "Confirm";
    }
  }

  void _handlePostStatus() async {
    try {
      String newStatus;
      switch (orderState) {
        case OrderState.reserved:
          newStatus = 'confirmed'; // Update post_status to 'confirmed'
          orderState = OrderState.confirmed;
          break;
        case OrderState.confirmed:
          newStatus = 'delivering'; // Update post_status to 'delivering'
          orderState = OrderState.delivering;
          break;
        case OrderState.delivering:
          newStatus = 'readyToPickUp'; // Update post_status to 'readyToPickUp'
          orderState = OrderState.readyToPickUp;
          break;
        case OrderState.readyToPickUp:
          newStatus = 'confirmed'; // Update post_status back to 'confirmed'
          orderState = OrderState.confirmed;
          break;
      }

      // Update the post_status field in Firestore
      await FirebaseFirestore.instance
          .collection('post_details')
          .doc(widget.postId)
          .update({'post_status': newStatus});

      setState(() {});
    } catch (error) {
      print('Error updating post status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update post status. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // OrderState _getNextOrderState() {
  //   switch (orderState) {
  //     case OrderState.reserved:
  //       return OrderState.confirmed;
  //     case OrderState.confirmed:
  //       return OrderState.delivering;
  //     case OrderState.delivering:
  //       return OrderState.readyToPickUp;
  //     case OrderState.readyToPickUp:
  //       return OrderState.reserved;
  //   }
  // }

  Widget _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            spreadRadius: 1,
            blurRadius: 16,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: CupertinoColors.tertiarySystemBackground,
        borderRadius: BorderRadius.circular(100.0),
        onPressed: () {
          _handleCancelOrder();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.x,
              color: CupertinoColors.systemRed,
            ),
            SizedBox(width: 8),
            Text(
              "Cancel",
              style: TextStyle(
                  fontSize: adjustedFontSize,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.label, context),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCancelOrder() async {
    // Show a confirmation dialog
    bool confirmCancel = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Cancel Order"),
          content: Text("Are you sure you want to cancel this order?"),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false); // Return false to indicate cancel
              },
            ),
            CupertinoDialogAction(
              child: Text("Confirm"),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, true); // Return true to indicate confirm
              },
            ),
          ],
        );
      },
    );

    // If the user confirms the cancelation, proceed with canceling the order
    if (confirmCancel == true) {
      try {
        // Get the user document
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(reservedByUserId)
            .get();

        // Check if data exists
        if (userSnapshot.exists) {
          // Get the current reserved posts of the user
          List<String> reservedPosts =
              List<String>.from(userSnapshot.data()?['reserved_posts'] ?? []);

          // Remove the postId of the canceled order
          reservedPosts.remove(widget.postId);

          // Update the user document with the updated reserved_posts list
          await FirebaseFirestore.instance
              .collection('user')
              .doc(reservedByUserId)
              .update({'reserved_posts': reservedPosts});
        }

        // Update the reserved_by and post_status fields in the post_details document 
        await FirebaseFirestore.instance
            .collection('post_details')
            .doc(widget.postId)
            .update({
          'reserved_by': FieldValue.delete(),
          'post_status': "not reserved"
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order cancelled successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        print('Error cancelling order: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildButtonAndCancelButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildButton(),
        ),
        SizedBox(width: 8), // Add some space between the buttons
        if (orderState != OrderState.readyToPickUp)
          Expanded(
            child: _buildCancelButton(),
          ),
      ],
    );
  }
}

class OrderInfoSection extends StatelessWidget {
  final String? reservedByName;
  final String? reservedByLastName;
  final double adjustedOrderInfoFontSize;
  final double rating;
  final String photo;

  const OrderInfoSection({
    Key? key,
    required this.reservedByName,
    required this.reservedByLastName,
    required this.adjustedOrderInfoFontSize,
    required this.rating,
    required this.photo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a default image if avatarUrl is empty or null
    // String effectiveAvatarUrl =
    //     avatarUrl.isEmpty ? 'assets/images/sampleProfile.png' : avatarUrl;

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Expanded(
          // Wrap the Container in an Expanded widget to take up remaining space
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CircleAvatar(
              //   backgroundImage: AssetImage(
              //       effectiveAvatarUrl), // Load the image from assets
              //   radius: 10,
              // ),
              photo.isNotEmpty
                ? CircleAvatar(
                    radius: 10,
                    backgroundImage: CachedNetworkImageProvider(photo),
                    onBackgroundImageError: (_, __) {
                      // Handle image load error
                    },
                    backgroundColor: Colors.transparent,
                  )
                : CircleAvatar(
                    radius: 10,
                    backgroundImage:
                        AssetImage('assets/images/sampleProfile.png'),
                  ),
              SizedBox(width: 8),
              Text(
                'Reserved by $reservedByName $reservedByLastName',
                style: TextStyle(
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withOpacity(0.8),
                  fontSize: adjustedOrderInfoFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Icon(
                Icons.star,
                color: secondaryColor,
                size: 14,
              ),
              const SizedBox(width: 3),
              Text(
                '${rating} Rating',
                style: TextStyle(
                  overflow: TextOverflow.fade,
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withOpacity(0.8),
                  fontSize: adjustedOrderInfoFontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.48,
                ),
              ),
            ],
          ),
        ));
  }
}