import 'package:FoodHood/Screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String message;

  SuccessScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              CupertinoIcons.check_mark_circled_solid,
              size: 120,
              color: Color.fromARGB(255, 51, 117, 134),
            ),
            SizedBox(height: 30),
            Text(
              'Success!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your password has been reset successfully.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 30),
            CupertinoButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => LogInScreen()),
                  (_) => false,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 51, 117, 134),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Continue to FoodHood',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.white, // Text color
                    ),
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
