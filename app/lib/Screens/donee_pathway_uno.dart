import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:FoodHood/Components/progress_bar.dart';
import 'package:FoodHood/Screens/donor_rating.dart';
import 'package:FoodHood/Components/PendingConfirmationWithTimer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Components/components.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:FoodHood/Screens/donor_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoneePath extends StatefulWidget {
  final String postId;

  DoneePath({required this.postId});

  @override
  _DoneePathState createState() => _DoneePathState();
}

class _DoneePathState extends State<DoneePath> {
  late PostDetailViewModel viewModel;
  late LatLng pickupLatLng;
  bool isLoading = true;
  OrderState orderState = OrderState.reserved;

  @override
  void initState() {
    super.initState();
    pickupLatLng = LatLng(49.8862, -119.4971);
    viewModel = PostDetailViewModel(widget.postId);
    viewModel.fetchData(widget.postId).then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Widget _buildLoadingScreen() {
    return Center(child: CupertinoActivityIndicator(radius: 16));
  }

  Widget _buildTextField({
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
            width: 0.0,
          ),
          color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
      ),
    );
  }

  Widget _buildMap(LatLng position) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0), // Adjust the corner radius
      child: Container(
        height: 200,
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: position, zoom: 14.4746),
          markers: {
            Marker(
                markerId: MarkerId("pickupLocation"),
                position: position,
                infoWindow: InfoWindow(title: "Pickup Location")),
          },
          onMapCreated: (GoogleMapController controller) {},
        ),
      ),
    );
  }

  Future<void> _launchMapUrl(LatLng locationCoordinates) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${locationCoordinates.latitude},${locationCoordinates.longitude}';
    final String appleMapsUrl =
        'http://maps.apple.com/?q=${locationCoordinates.latitude},${locationCoordinates.longitude}';

    HapticFeedback.selectionClick();
    // Check if the device is running on iOS
    if (Platform.isIOS) {
      // Attempt to open Apple Maps
      if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl);
      } else {
        throw 'Could not launch $appleMapsUrl';
      }
    } else {
      // Attempt to open Google Maps or the default map application on other devices
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    }
  }

  Widget _buildNavigateButton() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: CupertinoButton(
        onPressed: () => _launchMapUrl(viewModel.pickupLatLng),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.location_north_fill,
              color: CupertinoColors.white,
              size: 24.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'Navigate',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingNavigationBar() {
    return isLoading
        ? Container(width: 0, height: 0)
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Text('Message ${viewModel.firstName}',
                style: TextStyle(color: accentColor, fontSize: 16)),
          );
  }

  Widget _buildPostDetailsSection(Map<String, dynamic> data) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'You have reserved the ${viewModel.title} from ${viewModel.firstName}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ]));
  }

  Widget _buildProgressBar(String postStatus) {
    // Map the postStatus to OrderState for consistency
    final OrderState state = _mapStatusToOrderState(postStatus);

    // Calculate the progress based on the mapped state
    final double progress = _calculateProgress();

    return ProgressBar(
      progress: progress,
      labels: ["Reserved", "Confirmed", "Delivering", "Ready to Pick Up"],
      color: accentColor,
      // Assuming isReserved means any state other than 'not reserved'
      isReserved: postStatus != "not reserved",
      currentState: state,
    );
  }

  Widget _buildStatusDependentButton(String postStatus) {
    if (postStatus == "confirmed") {
      return _buildNavigateButton();
    } else {
      return Container();
    }
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.0), // Adjust the corner radius
      child: Container(
        height: 200,
        width: double.infinity,
        child: Image.network(
            viewModel.imagesWithAltText.isNotEmpty
                ? viewModel.imagesWithAltText[0]['url']!
                : 'default_image_url',
            fit: BoxFit.cover, errorBuilder: (BuildContext context,
                Object exception, StackTrace? stackTrace) {
          return const Icon(Icons.error);
        }),
      ),
    );
  }

  OrderState _mapStatusToOrderState(String postStatus) {
    switch (postStatus) {
      case 'pending':
        return orderState = OrderState.reserved;
      case 'confirmed':
        return orderState = OrderState.confirmed;
      case 'delivering':
        return orderState = OrderState.delivering;
      case 'readyToPickUp':
        return orderState = OrderState.readyToPickUp;
      default:
        return orderState = OrderState.reserved;
    }
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyC9ZK3lbbGSIpFOI_dl-JON4zrBKjMlw2A');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'] != null &&
          jsonResponse['results'].length > 0) {
        String address = jsonResponse['results'][0]['formatted_address'];
        return address;
      } else {
        return 'Location not found';
      }
    } else {
      throw Exception('Failed to fetch address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.black,
          ),
          trailing: _buildTrailingNavigationBar(),
          border: null,
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('post_details')
                .doc(widget.postId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: Text('Document not found.'));
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;
              var postStatus = data['post_status'] ?? 'not reserved';
              orderState = _mapStatusToOrderState(postStatus);
              if (data['post_location'] is GeoPoint) {
                GeoPoint geoPoint = data['post_location'] as GeoPoint;
                pickupLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);
              } else {
                pickupLatLng = LatLng(49.8862, -119.4971);
              }

              return SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'You have reserved the ${viewModel.title} from ${viewModel.firstName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Made by ${viewModel.firstName} ${viewModel.lastName}    Posted ${viewModel.timeAgoSinceDate(viewModel.postTimestamp)}',
                      style: TextStyle(
                        color: CupertinoColors.label
                            .resolveFrom(context)
                            .withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.48,
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildProgressBar(postStatus),
                    if (postStatus == 'confirmed' ||
                        postStatus == 'delivering' ||
                        postStatus == 'readyToPickUp')
                      Column(
                        children: [
                          _buildMap(LatLng(49.8862, -119.4971)),
                          FutureBuilder<String>(
                            future: getAddressFromLatLng(pickupLatLng),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return _buildTextField(
                                    text: "Pickup from ${snapshot.data}");
                              }
                            },
                          ),
                        ],
                      ),
                    if (postStatus == 'pending') _buildImageSection(),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        if (postStatus == "confirmed" ||
                            postStatus == "delivering" ||
                            postStatus == "readyToPickUp")
                          Expanded(
                            child: _buildNavigateButton(),
                          ),
                        if (postStatus == "pending" ||
                            postStatus == "not reserved")
                          Expanded(
                            child: PendingConfirmationWithTimer(
                              durationInSeconds: 500,
                              postId: widget.postId,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),
                    if (postStatus != "readyToPickUp")
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          onPressed: () {
                            _handleCancelReservation();
                          },
                          color: CupertinoColors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          borderRadius: BorderRadius.circular(30.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.xmark,
                                color: CupertinoColors.destructiveRed,
                                size: 24.0,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Cancel Order',
                                style: TextStyle(
                                  color: CupertinoColors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 0.0),
                    if (postStatus == "readyToPickUp")
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          onPressed: _navigateToRatingPage,
                          color: CupertinoColors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          borderRadius: BorderRadius.circular(30.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                color: CupertinoColors.systemYellow,
                                size: 24.0,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Leave a Review',
                                style: TextStyle(
                                  color: CupertinoColors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 50),
                  ],
                ),
              ));
            },
          ),
        ));
  }

  void _handleCancelReservation() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (userSnapshot.exists) {
        List<String> reservedPosts =
            List<String>.from(userSnapshot.data()?['reserved_posts'] ?? []);
        reservedPosts.remove(widget.postId);
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .update({'reserved_posts': reservedPosts});
      }
      await FirebaseFirestore.instance
          .collection('post_details')
          .doc(widget.postId)
          .update({
        'reserved_by': FieldValue.delete(),
        'post_status': "not reserved"
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reservation cancelled successfully.'),
          duration: Duration(seconds: 2)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to cancel reservation. Please try again.'),
          duration: Duration(seconds: 2)));
    }
  }

  void _navigateToRatingPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DonorRatingPage(postId: widget.postId),
      ),
    );
  }

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
}
