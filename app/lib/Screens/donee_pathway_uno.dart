import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class doneePath extends StatefulWidget {
  @override


  _doneePath createState() => _doneePath{

  }
}

class ReservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            // Handle back action
          },
        ),
        middle: Text('Reservation'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Handle message Harry action
          },
          child: Text('Message Harry'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You have reserved the Chicken and Rice from Harry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'path/to/your/image.jpg', // Replace with your image asset or network image.
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted by Harry Styles 2 mins ago',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    CupertinoIcons.star_fill,
                    color: Colors.amber,
                  ),
                  Text('5.0 Rating')
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: CupertinoButton.filled(
                    child: Text('Cancel Reservation'),
                    onPressed: () {
                      // Handle cancel reservation action
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
