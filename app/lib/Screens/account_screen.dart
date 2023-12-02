import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/profile_card.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Screens/profile_edit_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int segmentedControlGroupValue =
      0; // Initialize with 'Active Orders' selected.
  List<OrderCard> activeOrders = [
    OrderCard(
      imageLocation: 'assets/images/sampleFoodPic.png',
      title: 'Poutine',
      tags: ['GL Free', 'PVC Free'],
      orderInfo: 'Ordered on September 21, 2023',
    ),
    OrderCard(
      imageLocation: 'assets/images/sampleFoodPic.png',
      title: 'Burger',
      tags: ['Vegan', 'Organic'],
      orderInfo: 'Ordered on September 22, 2023',
    ),
    // Add more OrderCard widgets as needed
  ];
  List<OrderCard> pastOrders = [];

  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> myTabs = const <int, Widget>{
      0: Text('Active Orders',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      1: Text('Past Orders',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    };

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(context),
          SliverToBoxAdapter(
              child: ProfileCard()), // Display the profile card
                 
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
      backgroundColor: CupertinoColors.systemGroupedBackground,
      largeTitle: Text('Account', style: TextStyle(letterSpacing: -1.34)),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Color(0xFF337586))),
        onPressed: () => _navigateToSettings(context),
      ),
      border: Border(bottom: BorderSide.none),
      stretch: true, // Enable stretch behavior
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => EditProfilePage()));
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
        // Replace this with the logic to check if there are active orders
        if (activeOrders.isNotEmpty) {
          return _buildActiveOrdersSliver(activeOrders);
        } else {
          return _buildPlaceholderText();
        }
      case 1:
        // Replace this with the logic to check if there are past orders
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
      hasScrollBody: false, // Prevents the sliver from being scrollable
      child: SizedBox(
        height: 200, // Set a fixed height here
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FeatherIcons.box,
                size: 40,
                color: CupertinoColors.systemGrey,
              ),
              SizedBox(
                  height: 20), // Provides spacing between the icon and text
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

  // New method to build the Edit Profile button
  Widget _buildEditProfileButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CupertinoButton(
          color: Color(0xFF337586),
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
