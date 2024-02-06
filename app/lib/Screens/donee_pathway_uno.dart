import 'package:FoodHood/Screens/donee_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';

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

  void _navigateToRatingPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DoneeRatingPage(postId: widget.postId),
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
                child: Text('Message ${viewModel.firstName}'),
              ),
        border: null,
        middle: Text('Reservation'),
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80),
                    Text(
                      'You have reserved the ${viewModel.title} from ${viewModel.firstName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                          'Posted by ${viewModel.firstName} ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: Colors.amber,
                          size: 14,
                        ),
                        Text(
                          ' ${viewModel.rating.toStringAsFixed(1)} Rating ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          viewModel.timeAgoSinceDate(viewModel.postTimestamp),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    SizedBox(height: 20),
                    CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: _navigateToRatingPage,
                      child: Text('Leave a Review'),
                    ),
                    SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 94, vertical: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFF9FD0C6),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Pending Confirmation',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    CupertinoButton(
                      onPressed: () {},
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(18.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.destructiveRed,
                            size: 20.0,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Cancel Reservation',
                            style: TextStyle(
                              color: CupertinoColors.destructiveRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
