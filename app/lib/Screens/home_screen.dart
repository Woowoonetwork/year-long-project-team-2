import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildBottomButton(Icons.home, 'Home'),
            _buildBottomButton(Icons.search, 'Search'),
            _buildBottomButton(Icons.more_horiz, 'More'),
            _buildBottomButton(Icons.settings, 'Settings'),
            _buildBottomButton(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}

Widget _buildBottomButton(IconData icon, String label) {
  return TextButton(
    onPressed: () {
      // Implement your button functionality here
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}

class ResponsivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    double deviceWidth = mediaQuery.size.width;

    return SingleChildScrollView(
      child: Container(
        width: deviceWidth,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Color(0xFFEEEEEE)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: deviceWidth * 0.2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Discover',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildSearchBar(deviceWidth),
            _buildCategoryBar(),
            _buildCard(deviceWidth, 'Chicken and Rice', 'GL Free', 'PVC Free',
                'Posted by Jason Bean', '24 mins ago'),
            _buildCard(deviceWidth, 'Free Burgers!!!', 'Some tag', 'No Pickles',
                'Posted by Lily Moore', '32 mins ago'),
            _buildCard(deviceWidth, 'Idk what they are', 'Some tag',
                'No Pickles', 'Posted by Lily Moore', '32 mins ago'),
            _buildCard(deviceWidth, 'Plain burgers eeeeeek', 'Some tag',
                'No Pickles', 'Posted by Taylor Swift', '32 mins ago'),
            _buildCard(deviceWidth, 'Plain burgers eeeeeek', 'Some tag',
                'No Pickles', 'Posted by Taylor Swift', '32 mins ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double width) {
    return Container(
      width: width * 0.9,
      height: 40,
      margin: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Search',
          style: TextStyle(
            color: Color(0xFF626262),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCategory('All', Color.fromARGB(255, 42, 92, 71)),
        _buildCategory('Vegan', Color.fromARGB(255, 201, 204, 44)),
        _buildCategory('Italian', Color.fromARGB(255, 207, 51, 51)),
        _buildCategory('Halal', Color.fromARGB(255, 34, 174, 240)),
        _buildCategory('Vegetarian', Color.fromARGB(255, 223, 46, 214)),
      ],
    );
  }

  Widget _buildCategory(String name, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        name,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCard(double width, String title, String tag1, String tag2,
      String postedBy, String timeAgo) {
    return Container(
      width: width * 0.9,
      margin: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 20,
              offset: Offset(0, 0),
              spreadRadius: 0)
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: width * 0.9 * (110 / 382),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://via.placeholder.com/382x110"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Row(
                  children: [
                    _buildTag(tag1),
                    SizedBox(width: 7),
                    _buildTag(tag2),
                  ],
                ),
                SizedBox(height: 10),
                Text("$postedBy - $timeAgo",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          color: Color(0x7FF8CE53), borderRadius: BorderRadius.circular(20)),
      child: Text(name,
          style: TextStyle(
              color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
