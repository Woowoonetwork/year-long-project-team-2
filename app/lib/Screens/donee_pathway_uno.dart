import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:FoodHood/Screens/donor_rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoneePath extends StatefulWidget {
  final String postId;

  DoneePath({required this.postId});

  @override
  _DoneePathState createState() => _DoneePathState();
}

class _DoneePathState extends State<DoneePath> {
  late PostDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PostDetailViewModel(widget.postId);
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post_details')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CupertinoPageScaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return CupertinoPageScaffold(
            child: Center(child: Text('No data available')),
          );
        }

        // Update viewModel with the latest snapshot
        viewModel.updateFromSnapshot(snapshot.data!);

        return CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.black,
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Text('Message ${viewModel.firstName}'),
            ),
            border: null,
            middle: Text('Reservation'),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'You have reserved the ${viewModel.title} from ${viewModel.firstName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(_confirmationStatus()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _confirmationStatus() {
    if (viewModel.isReserved == "yes") {
      return 'Order Confirmed';
    } else if (viewModel.isReserved == "pending") {
      return 'Pending Confirmation';
    } else {
      return 'Reservation Status Unknown';
    }
  }
}
