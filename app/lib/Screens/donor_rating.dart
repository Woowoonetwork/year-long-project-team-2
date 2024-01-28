import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';

class DonorRatingPage extends StatefulWidget {
  @override
  _DonorRatingPageState createState() => _DonorRatingPageState();
}

class _DonorRatingPageState extends State<DonorRatingPage> {
  int _rating = 0; // State variable to keep track of the rating
  TextEditingController _commentController =
      TextEditingController(); // Initialize the text controller

  @override
  void dispose() {
    _commentController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('', style: TextStyle(letterSpacing: -1.34)),
            border: Border(bottom: BorderSide.none),
            backgroundColor: groupedBackgroundColor,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.chevronLeft,
                  size: 22, color: CupertinoColors.label.resolveFrom(context)),
            ),
            trailing: GestureDetector(
              onTap: () {
                print("Message Harry Tapped");
              },
              child: Text(
                'Message Harry',
                style:
                    TextStyle(color: CupertinoColors.activeBlue, fontSize: 17),
              ),
            ),
          ),
          // ... [Your existing code for the navigation bar] ...
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  child: Text(
                    "How was your experience with Harry?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.systemGrey4,
                    border:
                        Border.all(color: CupertinoColors.systemGrey, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera,
                    size: 40,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        _rating > index ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      iconSize: 40,
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16), // Padding for the text field
                  child: CupertinoTextField(
                    controller: _commentController,
                    maxLines:
                        3, // Increased maxLines to make the text field taller
                    placeholder: 'Write your comments here',
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(
                        color: CupertinoColors.systemGrey3,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.all(12), // Internal padding for text content
                  ),
                ),
                SizedBox(height: 40),

                Center(
                  child: CupertinoButton(
                    onPressed: () {
                      // Add your action for the publish button here
                      print("Publish button pressed");
                    },
                    color: CupertinoColors.activeBlue,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // To center the icon and text
                      children: [
                        Icon(Icons.publish,
                            size: 20), // Icon for the publish button
                        SizedBox(width: 4), // Spacing between icon and text
                        Text("Publish"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // ... [Any other widgets you might want to add] ...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
