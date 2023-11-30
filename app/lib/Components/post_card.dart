import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PostCard extends StatelessWidget {
  final String firstname;
  final String lastname;
  final String title;
  final List<String> tags;
  final String timeAgo;

  // Define your colors here
  final List<Color> colors = [
    Colors.lightGreenAccent, // Light Green
    Colors.lightBlueAccent, // Light Blue
    Colors.pinkAccent[100]!, // Light Pink
    Colors.yellowAccent[100]! // Light Yellow
  ];

  PostCard(
      {Key? key,
      required this.title,
      required this.tags,
      required this.firstname,
      required this.lastname,
      required this.timeAgo})
      : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding here
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

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
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
      child: Wrap(
        spacing: 8,
        children: tags
            .map((tag) => _buildTag(tag.trim(), _getRandomColor()))
            .toList(),
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Posted by $firstname $lastname $timeAgo',
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

  Color _getRandomColor() {
    var random = math.Random();
    return colors[random.nextInt(colors.length)];
  }
}
