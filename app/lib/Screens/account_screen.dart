/* 

Account Screen

- The account screen is the screen that displays the user's profile information and orders.

*/

import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/profile_card.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';

//Constants for styling
const double _defaultTextFontSize = 16.0;
const double _defaultTabTextFontSize = 14.0;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int segmentedControlGroupValue = 0;
  List<Widget> activeDonatedOrders = [];
  List<OrderCard> pastDonatedOrders = [];
  List<Widget> activeReservedOrders = [];
  List<OrderCard> pastReservedOrders = [];
  late double _textScaleFactor;
  late double adjustedTextFontSize;
  late double adjustedTabTextFontSize;

  @override
  void initState() {
    super.initState();
    setUpPostStreamListener();
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
  }

  void setUpPostStreamListener() {
    final String currentUserUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Update My Donations
    FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .where('user_id', isEqualTo: currentUserUID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var activeDonatedDocs = snapshot.docs
            .where((doc) => doc['post_status'] != 'completed')
            .toList();
        var pastDonatedDocs = snapshot.docs
            .where((doc) => doc['post_status'] == 'completed')
            .toList();
        if (mounted) {
          updateDonatedActiveOrders(activeDonatedDocs);
          updateDonatedPastOrders(pastDonatedDocs);
        }
      }
    });

    // Update My Reservations
    FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .where('reserved_by', isEqualTo: currentUserUID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var activeReservedDocs = snapshot.docs
            .where((doc) => doc['post_status'] != 'completed')
            .toList();
        var pastReservedDocs = snapshot.docs
            .where((doc) => doc['post_status'] == 'completed')
            .toList();
        if (mounted) {
          updateReservedActiveOrders(activeReservedDocs);
          updateReservedPastOrders(pastReservedDocs);
        }
      }
    });

    // FirebaseFirestore.instance
    //     .collection('post_details')
    //     .where('reserved_by', isEqualTo: currentUserUID) // Include posts reserved by the user
    //     .snapshots()
    //     .listen((snapshot) {
    //   var reservedDocs = snapshot.docs;
    //   if (mounted) {
    //     mergeReservedOrders(reservedDocs); // Handling reserved orders
    //   }
    // });
  }

  void updateDonatedActiveOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      activeDonatedOrders = documents.map((doc) {
        return createOrderCard(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  void updateDonatedPastOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      pastDonatedOrders = documents
          .map((doc) =>
              createOrderCard(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  void updateReservedActiveOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      activeReservedOrders = documents.map((doc) {
        return createOrderCard(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  void updateReservedPastOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      pastReservedOrders = documents
          .map((doc) =>
              createOrderCard(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  void _updateAdjustedFontSize() {
    adjustedTextFontSize = _defaultTextFontSize * _textScaleFactor;
    adjustedTabTextFontSize = _defaultTabTextFontSize * _textScaleFactor;
  }


  // Merge Reserved Orders into active orders
  // void mergeReservedOrders(List<QueryDocumentSnapshot> reservedDocs) {
  //   setState(() {
  //     // Add reserved orders under the active orders tab
  //     var mergedOrders = reservedDocs.map((doc) => createOrderCard(doc.data() as Map<String, dynamic>, doc.id)).toList();
  //     activeOrders.addAll(mergedOrders);
  //   });
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  void _onOrderCardTap(String postId) {
    setState(() {
      postId = postId;
    });
    print(postId + 'accountscreen');
  }

  OrderCard createOrderCard(Map<String, dynamic> documentData, String postId) {
    String title = documentData['title'] ?? 'No Title';
    List<String> tags = documentData['categories'].split(',');
    DateTime createdAt = (documentData['post_timestamp'] as Timestamp).toDate();

    List<Map<String, String>> imagesWithAltText = [];
    if (documentData.containsKey('images') && documentData['images'] is List) {
      imagesWithAltText = List<Map<String, String>>.from(
        (documentData['images'] as List).map((image) {
          return {
            'url': image['url'] as String? ?? '',
            'alt_text': image['alt_text'] as String? ?? '',
          };
        }),
      );
    }

    return OrderCard(
      title: title,
      tags: tags,
      orderInfo: 'Posted on ${DateFormat('MMMM dd, yyyy').format(createdAt)}',
      postId: postId,
      onTap: _onOrderCardTap,
      imagesWithAltText: imagesWithAltText,
      orderState: OrderState.confirmed,
    );
  }

  String getCurrentUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    _textScaleFactor = Provider.of<TextScaleProvider>(context).textScaleFactor;
    _updateAdjustedFontSize();

    final Map<int, Widget> myTabs = <int, Widget>{
      0: Text(
        'My Donations',
        style: TextStyle(
          fontSize: adjustedTabTextFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      1: Text(
        'My Reservations',
        style: TextStyle(
            fontSize: adjustedTabTextFontSize, fontWeight: FontWeight.w500),
      ),
    };

    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(context),
          SliverToBoxAdapter(child: ProfileCard()), // Display the profile card
          _buildSegmentControl(myTabs),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100.0),
            sliver: _buildOrdersContent(segmentedControlGroupValue),
          ),
        ],
      ),
    );
  }

  CupertinoSliverNavigationBar _buildNavigationBar(BuildContext context) {
    return CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor:
          CupertinoDynamicColor.resolve(groupedBackgroundColor, context)
              .withOpacity(0.8),
      largeTitle: Text('Account'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w500, color: accentColor)),
        onPressed: () => _navigateToSettings(context),
      ),
      border: Border(bottom: BorderSide.none),
      stretch: true, // Enable stretch behavior
    );
  }

  void _navigateToSettings(BuildContext context) {
    // Implement navigation to settings screen
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => SettingsScreen()));
  }

  SliverToBoxAdapter _buildOrdersSectionTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Text('Orders',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6)),
      ),
    );
  }

  SliverToBoxAdapter _buildSegmentControl(Map<int, Widget> myTabs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: CupertinoSlidingSegmentedControl<int>(
          children: myTabs,
          onValueChanged: (int? newValue) {
            if (newValue != null) {
              setState(() => segmentedControlGroupValue = newValue);
            }
          },
          groupValue: segmentedControlGroupValue,
        ),
      ),
    );
  }

  Widget _buildOrdersContent(int segmentedValue) {
    switch (segmentedValue) {
      case 0:
        if (activeDonatedOrders.isNotEmpty) {
          return _buildActiveOrdersSliver(activeDonatedOrders);
        } else {
          return _buildPlaceholderText();
        }
      case 1:
        if (pastDonatedOrders.isNotEmpty) {
          return _buildPastOrdersSliver(pastDonatedOrders);
        } else {
          return _buildPlaceholderText();
        }
      default:
        return SliverToBoxAdapter(
            child: Text('Content for the selected segment'));
    }
  }

  SliverList _buildActiveOrdersSliver(List<Widget> activeOrders) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: activeOrders[index],
        ),
        childCount: activeOrders.length,
      ),
    );
  }

  SliverList _buildPastOrdersSliver(List<Widget> activeOrders) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: pastDonatedOrders[index],
        ),
        childCount: pastDonatedOrders.length,
      ),
    );
  }

// Method to build the placeholder text when there are no orders
  SliverFillRemaining _buildPlaceholderText() {
    return SliverFillRemaining(
      hasScrollBody: false, // Prevents the sliver from being scrollable
      child: SizedBox(
        height: 50,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FeatherIcons.shoppingBag,
                size: 40,
                color: CupertinoColors.systemGrey,
              ),
              SizedBox(height: 20),
              Text(
                'No orders available',
                style: TextStyle(
                  fontSize: adjustedTextFontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.6,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
