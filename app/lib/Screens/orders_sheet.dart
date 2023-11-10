import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PastOrdersScreen extends StatefulWidget {
  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
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
              child: const 
                  Text('Close', style: TextStyle(color: Color(0xFF337586))),
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
            hasScrollBody: false,
            child: Center(
              child: _buildContent(
                  segmentedControlGroupValue), // Display the content based on the selected segment.
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int segmentedValue) {
    // The content that changes based on which tab is selected.
    switch (segmentedValue) {
      case 0:
        return Text('Active orders will appear here');
      case 1:
        return Text('Past orders will appear here');
      default:
        return Text('Content for the selected segment');
    }
  }
}

void showPastOrdersSheet(BuildContext context) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (BuildContext context) =>
        PastOrdersScreen(), // Use the StatefulWidget for the modal content.
    useRootNavigator: true,
  );
}
