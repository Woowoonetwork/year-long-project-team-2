// main.dart
// entry point of the app

import 'package:FoodHood/Screens/posting_detail.dart';
import 'package:FoodHood/Screens/home_screen.dart';
import 'package:FoodHood/Screens/login_screen.dart';
import 'package:FoodHood/Screens/navigation_screen.dart';
import 'package:FoodHood/Screens/posting_detail.dart';
import 'package:FoodHood/Screens/registration_screen.dart';
import 'package:FoodHood/Screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:FoodHood/auth_wrapper.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:FoodHood/firestore_service.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Call the function to add a pre-defined list of allergens and categories
  await addAllergensCategoriesAndPL();

  // Run the app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]) // Restrict orientation to portrait
      .then((_) {
    runApp(FoodHoodApp());
  });
}

class FoodHoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: AuthWrapper(), // Use AuthWrapper as the root widget
      debugShowCheckedModeBanner:
          false, // Hide the debug banner in Preview mode
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return CupertinoPageRoute(
              builder: (context) => WelcomeScreen(), // Root route
            );

          case '/signup':
            return CupertinoPageRoute(
              builder: (context) => RegistrationScreen(
                  auth: AuthService(FirebaseAuth.instance)), // Signup route
            );
          case '/signin':
            return CupertinoPageRoute(
              builder: (context) => LogInScreen(),
            );
          case '/home':
            return CupertinoPageRoute(
              builder: (context) => HomeScreen(),
            );
          case '/nav':
            return CupertinoPageRoute(
              builder: (context) => NavigationScreen(
                selectedIndex: ModalRoute.of(context)?.settings.arguments as int? ?? 0,
                onItemTapped: (index) {},
              ),
            );

          case '/posting':
            return CupertinoPageRoute(
              builder: (context) => PostDetailView(),
            );
          default:
            return CupertinoPageRoute(
              builder: (context) => HomeScreen(),
            );
        }
      },
    );
  }
}
