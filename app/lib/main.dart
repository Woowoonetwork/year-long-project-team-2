import 'package:FoodHood/Screens/home_screen.dart';
import 'package:FoodHood/Screens/login_screen.dart';
import 'package:FoodHood/Screens/navigation_screen.dart';
import 'package:FoodHood/Screens/registration_screen.dart';
import 'package:FoodHood/Screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:FoodHood/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await addAllergensCategoriesAndPL();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(FoodHoodApp());
  });
}

class FoodHoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Map<String, WidgetBuilder> routes = {
      '/': (context) => WelcomeScreen(),
      '/signup': (context) =>
          RegistrationScreen(auth: AuthService(FirebaseAuth.instance)),
      '/signin': (context) => LogInScreen(),
      '/home': (context) => HomeScreen(),
      '/nav': (context) => NavigationScreen(
            selectedIndex:
                ModalRoute.of(context)?.settings.arguments as int? ?? 0,
            onItemTapped: (index) {},
          ),
    };

    // Provide a default route in case the specified route name is not found
    WidgetBuilder builder = routes[settings.name] ?? (context) => HomeScreen();

    return CupertinoPageRoute(
      builder: builder,
      settings: settings,
    );
  }
}
