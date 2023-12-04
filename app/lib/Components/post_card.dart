import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:FoodHood/Screens/posting_detail.dart';

String x = "GL Free";

class PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("GestureDetector tapped");

        // Navigate to the post detail page when the card is tapped
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => PostDetailView()),
        );
      },
      child: Center(
        child: Container(
          width: 382,
          height: 220,
          decoration: _buildBoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              _buildTitleSection(),
              _buildTagSection(),
              _buildOrderInfoSection(),
            ],
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

  // Widget _buildImageSection() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
  //     child: Image.asset(
  //       "../../assets/images/382x110.png", // Ensure this image is available in your assets
  //       width: 382,
  //       height: 110,
  //       fit: BoxFit.fill,
  //     ),
  //   );
  // }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        'Poutine',
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _buildTag(x, Color(0x7FF8CE53)),
          const SizedBox(width: 7),
          _buildTag('PVC Free', Color(0x7FFF8C5B)),
        ],
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
      child: Row(
        children: [
          // Image or placeholder
          Container(
            width: 24, // Set the width of the image placeholder
            height: 24, // Set the height of the image placeholder
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey, // Placeholder color
              // Uncomment below and replace 'path/to/your/image' with actual image path
              // image: DecorationImage(
              //   image: AssetImage('path/to/your/image'),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          SizedBox(width: 8), // Space between image and text
          // Text
          Text(
            'Posted by Jason Bean   24 mins ago',
            style: TextStyle(
              color: CupertinoColors.black.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
