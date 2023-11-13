import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:FoodHood/Components/order_card.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int segmentedControlGroupValue =
      0; // Initialize with 'Active Orders' selected.

  @override
  Widget build(BuildContext context) {
    // Define your segmented control tabs.
    final Map<int, Widget> myTabs = const <int, Widget>{
      0: Text(
        'Active Orders',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      1: Text(
        'Past Orders',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    };

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            automaticallyImplyLeading: false,
            backgroundColor: CupertinoColors.systemBackground,
            border: const Border(bottom: BorderSide.none),
            largeTitle:
                const Text('Orders', style: TextStyle(letterSpacing: -1.36)),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFF337586))),
              onPressed: () =>
                  Navigator.pop(context), // Dismiss the modal bottom sheet.
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width:
                    double.infinity, // Ensures the control takes up full width.
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
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Center(
              child: _buildContent(
                  segmentedControlGroupValue), // Display the content based on the selected segment.
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildContent(int segmentedValue) {
  // The content that changes based on which tab is selected.
  switch (segmentedValue) {
    case 0:
      return _buildActiveOrders(); // Call _buildActiveOrders to display active orders.
    case 1:
      return Text('Past orders will appear here');
    default:
      return Text('Content for the selected segment');
  }
}

Widget _buildActiveOrders() {
  // Sample data for active orders. In a real app, this would be fetched from a database or API.
  List<Widget> activeOrders = [
    OrderCard(), // Your OrderCard widget.
    // Add more OrderCard widgets or other widgets representing orders as needed.
  ];

  return ListView.builder(
    itemCount: activeOrders.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: activeOrders[index],
      );
    },
  );
}

void showPastOrdersSheet(BuildContext context) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (BuildContext context) =>
        OrdersScreen(), // Use the StatefulWidget for the modal content.
    useRootNavigator: true,
  );
}
