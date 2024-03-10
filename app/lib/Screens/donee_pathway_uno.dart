import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/slimProgressBar.dart';
import 'package:FoodHood/Screens/donor_rating.dart';
import 'package:FoodHood/Components/PendingConfirmationWithTimer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DoneePath extends StatefulWidget {
  final String postId;

  DoneePath({required this.postId});

  @override
  _DoneePathState createState() => _DoneePathState();
}

class _DoneePathState extends State<DoneePath> {
  late PostDetailViewModel viewModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

  Widget _buildMap(LatLng position) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: position, zoom: 14.4746),
      markers: {
        Marker(
            markerId: MarkerId("pickupLocation"),
            position: position,
            infoWindow: InfoWindow(title: "Pickup Location")),
      },
      onMapCreated: (GoogleMapController controller) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.black),
          trailing: isLoading
              ? Container(width: 0, height: 0)
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('post_details')
                      .doc(widget.postId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.data() == null) {
                      return Text('Loading...');
                    }
                    var firstName =
                        (snapshot.data!.data() as Map)['firstName'] ?? 'User';
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: Text('Message ${viewModel.firstName}',
                          style: TextStyle(color: accentColor, fontSize: 16)),
                    );
                  },
                ),
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
              var title = data['title'] ?? 'Item';
              var firstName = data['firstName'] ?? 'User';
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    ),
                    SlimProgressBar(
                      stepTitles: [
                        'Confirmed',
                        'Out for delivery',
                        'Ready for pickup',
                        'Complete'
                      ],
                      postStatus: postStatus,
                    ),
                    SizedBox(height: 20),
                    postStatus == 'confirmed'
                        ? _buildMap(LatLng(49.8862, -119.4971))
                        : Image.network(
                            viewModel.imagesWithAltText.isNotEmpty
                                ? viewModel.imagesWithAltText[0]['url']!
                                : 'default_image_url',
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Made by ${viewModel.firstName} ${viewModel.lastName} Posted ${viewModel.timeAgoSinceDate(viewModel.postTimestamp)}',
                          style: TextStyle(
                            color: CupertinoColors.label
                                .resolveFrom(context)
                                .withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.48,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${viewModel.rating}',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (postStatus == "confirmed")
                      CupertinoButton.filled(
                        onPressed: () {
                          // Action for the navigate button
                        },
                        child: Text('Navigate'),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    SizedBox(height: 10),
                    PendingConfirmationWithTimer(
                        durationInSeconds: 500, postId: widget.postId),
                    SizedBox(height: 15),
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
                    SizedBox(height: 20.0),
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
              );
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
}
