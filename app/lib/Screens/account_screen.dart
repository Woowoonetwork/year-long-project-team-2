import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/order_card.dart'; // Correct path for order_card.dart
import 'package:FoodHood/Components/profile_card.dart'; // Correct path for profile_card.dart
import 'package:FoodHood/Screens/profile_edit_screen.dart'; // Correct path for profile_edit_screen.dart

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int segmentedControlGroupValue =
      0; // Initialize with 'Active Orders' selected.

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
              child: ProfileCard(
                  onEditProfile: () => _navigateToEditProfile(context))),
          _buildOrdersSectionTitle(),
          _buildSegmentControl(myTabs),
          _buildOrdersContent(segmentedControlGroupValue),
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
        child: Text('Settings', style: TextStyle(color: Color(0xFF337586))),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        return _buildActiveOrdersSliver();
      case 1:
        return _buildPastOrdersSliver();
      default:
        return SliverToBoxAdapter(
            child: Text('Content for the selected segment'));
    }
  }

  SliverList _buildActiveOrdersSliver() {
    List<Widget> activeOrders = [
      OrderCard(),
      // Add more OrderCard widgets as needed
    ];

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

  SliverFillRemaining _buildPastOrdersSliver() {
    return SliverFillRemaining(
      hasScrollBody: false, // Prevents the sliver from being scrollable
      child: Center(
        child: Text(
          'Past orders will appear here',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign
              .center, // This is technically not needed as Center widget will take care of it.
        ),
      ),
    );
  }
}
