import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/donor_rating.dart';
import 'package:FoodHood/Screens/posting_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:FoodHood/Components/PendingConfirmationWithTimer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DoneePath extends StatefulWidget {
  final String postId;

  DoneePath({required this.postId});

  @override
  _DoneePathState createState() => _DoneePathState();
}

class _DoneePathState extends State<DoneePath> {
  late PostDetailViewModel viewModel;
  bool isLoading = true;
  bool isReserved = true;
  String postStatus = "";

  @override
  void initState() {
    super.initState();
    fetchPostDetails();
    viewModel = PostDetailViewModel(widget.postId);
    viewModel.fetchData(widget.postId).then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isReserved = true;
        });
      }
    });
  }

  void fetchPostDetails() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('post_details')
        .doc(widget.postId)
        .get();
    if (docSnapshot.exists) {
      setState(() {
        isLoading = false;
        postStatus = docSnapshot.data()?['post_status'] ?? "";
      });
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        trailing: isLoading
            ? Container()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: Text(
                  'Message ${viewModel.firstName}',
                  style: TextStyle(color: accentColor, fontSize: 16),
                ),
              ),
        border: null,
        // middle: Text('Reservation'),
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'You have reserved the ${viewModel.title} from ${viewModel.firstName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.network(
                      viewModel.imageUrl,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Made by ${viewModel.firstName} ${viewModel.lastName}   Posted ${viewModel.timeAgoSinceDate(viewModel.postTimestamp)}   ',
                          style: TextStyle(
                            color: CupertinoColors.label
                                .resolveFrom(context)
                                .withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.48,
                          ),
                        ),
                        Text(""),
                        RatingText(),
                      ],
                    ),
                    SizedBox(height: 50),
                    PendingConfirmationWithTimer(
                        durationInSeconds: 120, postId: widget.postId),
                    SizedBox(height: 40),
                    if (postStatus == "picked up")
                      CupertinoButton.filled(
                        onPressed: _navigateToRatingPage,
                        child: Text('Leave a Review'),
                        padding: EdgeInsets.symmetric(
                            horizontal: 36.0, vertical: 16.0),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    SizedBox(height: 0),
                    Container(
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
                            horizontal: 36.0, vertical: 16.0),
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
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
      ),
    );
  }

  void _handleCancelReservation() async {
    try {
      await FirebaseFirestore.instance
          .collection('post_details')
          .doc(widget.postId)
          .update({
        'reserved_by': FieldValue.delete(),
        'post_status': "not reserved"
      });

      setState(() {
        isReserved = false;
      });

      print("checkuno");
      Navigator.pop(context);
      print("checkdos");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation cancelled successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error cancelling reservation: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel reservation. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
