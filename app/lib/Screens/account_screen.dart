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
  List<Widget> activeOrders = [];
  List<OrderCard> pastOrders = [];
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
    String currentUserUID = getCurrentUserUID();

    // Active Orders Stream
    FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: currentUserUID)
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        updateActiveOrders(snapshot.docs);
      }
    }, onError: (error) => print('Error listening to active orders: $error'));

    // Past Orders Stream
    FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: currentUserUID)
        .where('status', isEqualTo: 'past') // Adjust based on your schema
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        updatePastOrders(snapshot.docs);
      }
    }, onError: (error) => print('Error listening to past orders: $error'));
  }

  void updatePastOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      pastOrders = documents
          .map((doc) =>
              createOrderCard(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // // Subscribe to changes in the entire collection to refresh the page when any new post is added
  // FirebaseFirestore.instance
  //     .collection('post_details')
  //     .orderBy('post_timestamp', descending: true)
  //     .snapshots()
  //     .listen((snapshot) {
  //   if (mounted) {
  //     // Refresh the page when any new post is added but the UI will only be updated for the current user's posts
  //     if (snapshot.docs.isNotEmpty) {
  //       updateActiveOrders(snapshot.docs);
  //     }
  //   }
  // });

  void _updateAdjustedFontSize() {
    adjustedTextFontSize = _defaultTextFontSize * _textScaleFactor;
    adjustedTabTextFontSize = _defaultTabTextFontSize * _textScaleFactor;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onOrderCardTap(String postId) {
    setState(() {
      postId = postId;
    });
    print(postId + 'accountscreen');
  }

  void updateActiveOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      activeOrders = documents.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var postId = doc.id;
        return createOrderCard(data, postId);
      }).toList();
    });
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
      orderState: getOrderState(documentData['post_status'] as String? ?? ''),
    );
  }

  OrderState getOrderState(String status) {
    switch (status) {
      case 'not reserved':
        return OrderState.pending;
      case 'confirmed':
        return OrderState.confirmed;
      case 'delivering':
        return OrderState.delivering;
      case 'readyToPickUp':
        return OrderState.readyToPickUp;
      case 'reserved':
        return OrderState.reserved;
      default:
        return OrderState.pending;
    }
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
        'Active Orders',
        style: TextStyle(
          fontSize: adjustedTabTextFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      1: Text(
        'Past Orders',
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
        if (activeOrders.isNotEmpty) {
          return _buildActiveOrdersSliver(activeOrders);
        } else {
          return _buildPlaceholderText();
        }
      case 1:
        if (pastOrders.isNotEmpty) {
          return _buildPastOrdersSliver(pastOrders);
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
          child: pastOrders[index],
        ),
        childCount: pastOrders.length,
      ),
    );
  }

  SliverFillRemaining _buildPlaceholderText() {
    return SliverFillRemaining(
      hasScrollBody: false,
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
