import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNavigationBar(),
        ],
      ),
    );
  }

  CupertinoSliverNavigationBar _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: groupedBackgroundColor,
      largeTitle: Text('Saved'),
      border: Border(bottom: BorderSide.none),
      stretch: true, // Enable stretch behavior
    );
  }
}
