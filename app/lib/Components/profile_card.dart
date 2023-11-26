import 'package:flutter/cupertino.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback onEditProfile;

  ProfileCard({required this.onEditProfile});

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
              ClipOval(
                child: Image.asset("assets/images/sampleProfile.png", // Replace with profile image
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover, // This is important to keep the image aspect ratio
                ),
              ),
              SizedBox(width: 16), // For spacing between image and text
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
            onPressed: onEditProfile, // Use the passed callback here
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
