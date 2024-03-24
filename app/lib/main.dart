import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Models/RemoteNotification.dart';
import 'package:FoodHood/Screens/browse_screen.dart';
import 'package:FoodHood/Screens/home_screen.dart';
import 'package:FoodHood/Screens/login_screen.dart';
import 'package:FoodHood/Screens/navigation_screen.dart';
import 'package:FoodHood/Screens/registration_screen.dart';
import 'package:FoodHood/Screens/welcome_screen.dart';
import 'package:FoodHood/Services/FirebaseService.dart';
import 'package:FoodHood/auth_wrapper.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Services/AuthService.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black.withOpacity(0.002),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); 

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseNotification().initNotifications();

  await addAllergensCategoriesAndPL();

  // Handling the dynamic link when the app is launched from a terminated state
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  // Setting up the dynamic link listener for foreground/background states
  FirebaseDynamicLinks.instance.onLink.listen(
    (dynamicLinkData) {
      // Handle dynamic link within your navigation logic
      // For example:
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
    },
    onError: (error) {
      // Handle errors
      print('Dynamic Link Failed: $error');
    },
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TextScaleProvider>(
            create: (context) => TextScaleProvider(),
          ),
        ],
        child: FoodHoodApp(initialLink: initialLink),
      ),
    );
  });
}

class FoodHoodApp extends StatelessWidget {
  final PendingDynamicLinkData? initialLink;

  const FoodHoodApp({super.key, this.initialLink});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      builder: FToastBuilder(),
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          navLargeTitleTextStyle: TextStyle(
              fontSize: 34,
              letterSpacing: -1.4,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label),
          navTitleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: CupertinoColors.label),
        ),
        barBackgroundColor: backgroundColor,
      ),
      title: 'FoodHood',
      home: AuthWrapper(), // Use AuthWrapper as the root widget
      debugShowCheckedModeBanner:
          false, // Hide the debug banner in Preview mode
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialWithModalsPageRoute(
              builder: (context) => WelcomeScreen(), // Root route
            );
          case '/signup':
            return MaterialWithModalsPageRoute(
              builder: (context) => RegistrationScreen(
                  auth: AuthService()), // Signup route
            );
          case '/signin':
            return MaterialWithModalsPageRoute(
              builder: (context) => LogInScreen(),
            );
          case '/home':
            return MaterialWithModalsPageRoute(
              builder: (context) => HomeScreen(),
            );
          case '/nav':
            return MaterialWithModalsPageRoute(
              builder: (context) => NavigationScreen(
                selectedIndex:
                    ModalRoute.of(context)?.settings.arguments as int? ?? 0,
                onItemTapped: (index) {},
              ),
            );
         
          case '/browse':
            return MaterialWithModalsPageRoute(
                builder: (context) => const BrowseScreen());
          default:
            return MaterialWithModalsPageRoute(
              builder: (context) => HomeScreen(),
            );
        }
      },
    );
  }
}
