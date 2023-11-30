import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class OrderCard extends StatelessWidget {
  final String imageLocation;
  final String title;
  final List<String> tags;
  final String orderInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  OrderCard({
    required this.imageLocation,
    required this.title,
    required this.tags,
    required this.orderInfo,
    this.onEdit, // Optional callback for editing
    this.onCancel, // Optional callback for canceling
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 220,
      child: CupertinoContextMenu(
        actions: <Widget>[
          // Edit Order Action
          CupertinoContextMenuAction(
            child: Text('Edit Order'),
            trailingIcon: CupertinoIcons.pencil,
            onPressed: () {
              onEdit?.call(); // Call the edit callback if it's provided
              Navigator.pop(context);
            },
          ),
          // Cancel Order Action
          CupertinoContextMenuAction(
            child: Text('Cancel Order'),
            trailingIcon: CupertinoIcons.trash,
            isDestructiveAction: true,
            onPressed: () {
              onCancel?.call(); // Call the cancel callback if it's provided
              Navigator.pop(context);
            },
          ),
        ],
        child: Container(
          decoration: _buildBoxDecoration(context),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Keep children left-aligned
            children: [
              // Center the image
              Center(
                child: _buildImageSection(context),
              ),
              // The rest of the sections are left-aligned
              _buildTitleSection(context),
              _buildTagSection(context),
              _buildOrderInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
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

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      child: Image.asset(
        imageLocation, // Use the provided image location
        width: MediaQuery.of(context).size.width,
        height: 110,
        fit: BoxFit.cover, // Crop image to scale
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title, // Use the provided title
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.label, context), // Use dynamic label color
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagSection(BuildContext context) {
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
              _buildTag(tags[index], tagColors[index],
                  context), // Use the provided tag
              SizedBox(width: horizontalSpacing), // Add spacing here
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.label, context), // Use dynamic label color
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        orderInfo, // Use the provided orderInfo
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel,
              context), // Use dynamic secondary label color
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
