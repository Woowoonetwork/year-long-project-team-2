import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/colors.dart';

const double _iconSize = 22.0;

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  _DonorScreenState createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  @override
  Widget build(BuildContext context) {
    //  double screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: backgroundColor,
            largeTitle: Text(
              'Donor Post',
            ),
            leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(FeatherIcons.x,
                    size: _iconSize, color: CupertinoColors.label.resolveFrom(context)),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text(
                'Message Donee',
                style: TextStyle(
                  color: Color(0xFF337586), // Your custom color
                ),
              ),
              onPressed: () {
                // Close the current screen
                Navigator.of(context).pop();
              },
            ),
            border: const Border(bottom: BorderSide.none),
            stretch: true,
          ),
        ],
      ),
    );
  }  
}