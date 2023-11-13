import 'package:flutter/cupertino.dart';

class FoodPosting extends StatefulWidget {
  const FoodPosting({Key? key}) : super(key: key);

  @override
FoodPostingState createState() =>FoodPostingState();
}

class FoodPostingState extends State<FoodPosting> {
   @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Image of Chicken and Rice'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('chickenrice.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Your Text Goes Here'),
          ],
        ),
      ),
      floatingActionButton: CupertinoButton.filled(
        child: Icon(CupertinoIcons.add),
        onPressed: () {
          // Add your onPressed logic here
          print('Floating Action Button Pressed');
        },
      ),
    );
  }
}