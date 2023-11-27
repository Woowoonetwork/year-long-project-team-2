import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCard extends StatelessWidget {

  ProfileCard();

  String getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'No email found';
  }

  String getCurrentUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'FoodHood User';
  }

  String getCurrentUserPhoto() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.photoURL ?? 'assets/images/sampleProfile.png';
  }

  String getCurrentUserLocation() {
    final user = FirebaseAuth.instance.currentUser;
    return 'Location not defined';
  }

  @override
  Widget build(BuildContext context) {
    String email = getCurrentUserEmail();
    String name = getCurrentUserName();
    String photo = getCurrentUserPhoto();

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
                child: Image.asset(
                  photo,
                  width: 70,
                  height: 70,
                  fit: BoxFit
                      .cover, // This is important to keep the image aspect ratio
                ),
              ),
              SizedBox(width: 16), // For spacing between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      getCurrentUserLocation(),
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
      ],
    );
  }
}
