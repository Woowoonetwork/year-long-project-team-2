import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class OrderCard extends StatelessWidget {
  final String imageLocation;
  final String title;
  final List<String> tags;
  final String orderInfo;

  OrderCard({
    required this.imageLocation,
    required this.title,
    required this.tags,
    required this.orderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 382,
      height: 220,
      child: CupertinoContextMenu(
        actions: <Widget>[
          CupertinoContextMenuAction(
            child: Text(
              'Edit Order',
              style: TextStyle(
                letterSpacing: -0.5,
              ),
            ),
            trailingIcon: CupertinoIcons.pencil,
            onPressed: () {
              // Implement the Edit Order functionality
              Navigator.pop(context);
            },
          ),
          CupertinoContextMenuAction(
            child: Text(
              'Cancel Order',
              style: TextStyle(
                letterSpacing:  -0.5,
              ),
            ),
            trailingIcon: CupertinoIcons.trash,
            isDestructiveAction: true,
            onPressed: () {
              // Implement the Cancel Order functionality
              Navigator.pop(context);
            },
          ),
        ],
        child: Center(
          child: Container(
            decoration: _buildBoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                _buildTitleSection(),
                _buildTagSection(),
                _buildOrderInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 20,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      child: Image.asset(
        imageLocation, // Use the provided image location
        width: 382,
        height: 110,
        fit: BoxFit.cover, // Crop image to scale
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title, // Use the provided title
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    const double horizontalSpacing = 7.0; // Adjust the spacing as needed
    List<Color> tagColors = [
      Color(0x7FF8CE53), // Color for the first tag
      Color(0x7FFF8C5B), // Color for the second tag, and so on
      // Add more colors for additional tags
    ];

    if (tags.length != tagColors.length) {
      throw ArgumentError("Number of tags and tagColors must match.");
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: List.generate(tags.length, (index) {
          return Row(
            children: [
              _buildTag(tags[index],
                  tagColors[index]), // Use the corresponding color for each tag
              SizedBox(width: horizontalSpacing), // Add spacing here
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        orderInfo, // Use the provided orderInfo
        style: TextStyle(
          color: CupertinoColors.black.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
