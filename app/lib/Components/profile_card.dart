import 'package:flutter/cupertino.dart';

class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withAlpha(25),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey2,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jason Bean',
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                      ),
                    ),
                    Text(
                      'Js123@gmail.com',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Kelowna, BC',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: CupertinoButton(
            color: Color(0xFF337586),
            borderRadius: BorderRadius.circular(10),
            minSize: 44, // Minimum tap area size
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              // TODO: Add your onTap functionality here
            },
            child: Text(
              'Edit FoodHood Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.8,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
