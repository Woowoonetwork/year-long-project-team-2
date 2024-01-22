import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/profile_card.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Screens/edit_profile_screen.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int segmentedControlGroupValue = 0;
  List<Widget> activeOrders = [];
  List<OrderCard> pastOrders = [];

  @override
  void initState() {
    super.initState();
    setUpPostStreamListener();
  }

  void setUpPostStreamListener() {
    String currentUserUID = getCurrentUserUID();
    FirebaseFirestore.instance
        .collection('post_details')
        .where('user_id', isEqualTo: currentUserUID)
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        if (snapshot.docs.isEmpty) {
          print('No posts found for the current user.');
        } else {
          // Update the active orders if posts are available
          updateActiveOrders(snapshot.docs);
        }
      }
    }, onError: (error) {
      if (error is FirebaseException && error.code == 'failed-precondition') {
        print('No Post Details index found.');
      } else {
        print('Error listening to post changes: $error');
      }
    });
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
        var data = doc.data();
        var postId = doc.id;
        if (data is Map<String, dynamic>) {
          return createOrderCard(data, postId);
        } else {
          print('Document data is not a Map<String, dynamic>');
          return SizedBox.shrink();
        }
      }).toList();
    });
  }

  OrderCard createOrderCard(Map<String, dynamic> documentData, String postId) {
    String title = documentData['title'] ?? 'No Title';
    List<String> tags = documentData['categories'].split(',');
    DateTime createdAt = (documentData['post_timestamp'] as Timestamp).toDate();

    return OrderCard(
      imageLocation: 'assets/images/sampleFoodPic.png',
      title: title,
      tags: tags,
      orderInfo: 'Ordered on ${DateFormat('MMMM dd, yyyy').format(createdAt)}',
      postId: postId,
      onTap: _onOrderCardTap,
    );
  }

  String getCurrentUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> myTabs = const <int, Widget>{
      0: Text('Active Orders',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      1: Text('Past Orders',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    };

    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(context),
          SliverToBoxAdapter(child: ProfileCard(userid: getCurrentUserUID())), // Pass userid here

          _buildEditProfileButton(), // New method to create the Edit Profile button

          _buildOrdersSectionTitle(),
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
      backgroundColor: groupedBackgroundColor,
      largeTitle: Text('Account', style: TextStyle(letterSpacing: -1.34)),
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

  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => EditProfilePage()),
    );

    if (result == 'updated') {
      setState(() {});
    }
  }

  void _navigateToSettings(BuildContext context) {
    // Implement navigation to settings screen
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => SettingsScreen()));
  }

  SliverToBoxAdapter _buildOrdersSectionTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
        child: Text('Orders',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.36)),
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
                FeatherIcons.box,
                size: 40,
                color: CupertinoColors.systemGrey,
              ),
              SizedBox(height: 20),
              Text(
                'No orders available',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the Edit Profile button
  Widget _buildEditProfileButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CupertinoButton(
          color: accentColor,
          borderRadius: BorderRadius.circular(10),
          minSize: 44,
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: () => _navigateToEditProfile(context),
          child: Text(
            'Edit FoodHood Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.8,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
