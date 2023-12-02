// registration_screen.dart
// a screen that allows users to register for an account

import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import '../components.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  final AuthService auth;

  RegistrationScreen({Key? key, required this.auth}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedProvince = '';
  String _selectedCity = '';

  List<String> provinces = []; // Updated to be fetched from Firestore
  Map<String, List<String>> cities = {}; // Updated to be fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchProvincesAndCities();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      navigationBar: buildBackNavigationBar(context),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: _buildSignupForm(context),
            ),
          ),
        ),
      ),
    );
  }

  // Sign up form
  Column _buildSignupForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildText(
            'Create an account', 34, FontWeight.w600), // Create an account text
        const SizedBox(height: 50),
        buildTwoFieldsRow(
          'First Name',
          _firstNameController,
          'Last Name',
          _lastNameController,
        ),
        const SizedBox(height: 20),
        buildCupertinoTextField('Email Address', _emailController, false,
            context), // Email text field
        const SizedBox(height: 20),
        buildCupertinoTextField('Password', _passwordController, true, context),
        const SizedBox(height: 20),
        buildTwoPickerFieldsRow(
          'Province',
          _selectedProvince,
          provinces,
          (value) {
            setState(() {
              _selectedProvince = value;
              _selectedCity = cities[_selectedProvince]?.first ?? '';
            });
          },
          'City',
          _selectedCity,
          cities[_selectedProvince] ?? [],
          (value) {
            setState(() {
              _selectedCity = value;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildContinueButton(context, 'Create account', accentColor,
            CupertinoColors.white),
        const SizedBox(height: 20),
        buildCenteredText('or', 14, FontWeight.w600), // Or text
        const SizedBox(height: 20),
        buildGoogleSignInButton(context), // Google sign in button
        const SizedBox(height: 20),
        buildSignUpText(context, "Already have an account? ", 'Sign in',
            '/signin'), // Sign up text
      ],
    );
  }

  Row buildTwoFieldsRow(
    String placeholder1,
    TextEditingController controller1,
    String placeholder2,
    TextEditingController controller2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: buildCupertinoTextField(
                placeholder1, controller1, false, context),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: buildCupertinoTextField(
                placeholder2, controller2, false, context),
          ),
        ),
      ],
    );
  }

 Row buildTwoPickerFieldsRow(
    String placeholder1,
    String currentValue1,
    List<String> options1,
    ValueChanged<String> onSelectedItemChanged1,
    String placeholder2,
    String currentValue2,
    List<String> options2,
    ValueChanged<String> onSelectedItemChanged2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: buildPickerField(
                context, placeholder1, currentValue1, options1, onSelectedItemChanged1),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: buildPickerField(
                context, placeholder2, currentValue2, options2, onSelectedItemChanged2),
          ),
        ),
      ],
    );
  }
  Widget _buildContinueButton(BuildContext context, String text,
      Color backgroundColor, Color textColor) {
    return CupertinoButton(
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          try {
            await widget.auth.signUp(
              email: _emailController.text,
              password: _passwordController.text,
            );
            // User registration successful
            print('User registered');
            String? userID = await widget.auth.getUserId();
            if (userID != null) {
              await addDocument(
                collectionName: 'user',
                filename: userID,
                fieldNames: [
                  'firstName',
                  'lastName',
                  'province',
                  'city',
                  'email',
                  'itemsSold',
                  'description',
                  'posts'
                ],
                fieldValues: [
                  _firstNameController.text,
                  _lastNameController.text,
                  _provinceController.text,
                  _cityController.text,
                  _emailController.text,
                  [],
                  '',
                  []
                ],
              );
              print("added new user doc");
            }
            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            // Handle registration errors
            print('Registration failed: $e');
          }
        }
      },
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void fetchProvincesAndCities() async {
    FirebaseFirestore.instance
        .collection('location')
        .doc('rLxaYnbNB4x6Rpvil1Oe')
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.get('location');
        Map<String, List<String>> fetchedCities = {};

        data.forEach((province, citiesList) {
          // Ensure the citiesList is a List of Strings
          if (citiesList is List) {
            fetchedCities[province] = List<String>.from(citiesList);
          }
        });

        if (fetchedCities.isNotEmpty) {
          setState(() {
            provinces = fetchedCities.keys.toList();
            cities = fetchedCities;
            // After fetching, set the initial province and city
            _selectedProvince = provinces.first;
            _selectedCity = cities[_selectedProvince]?.first ?? '';
          });
        }
      }
    }).catchError((error) {
      // Handle any errors here
      print("Error fetching data: $error");
    });
  }

  Widget buildPickerField(
      BuildContext context,
      String label,
      String currentValue,
      List<String> options,
      ValueChanged<String> onSelectedItemChanged) {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton(
            padding: EdgeInsets.all(12),
            color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground,context),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => _showCupertinoPicker(
                context, options, currentValue, onSelectedItemChanged),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(currentValue,
                      style: TextStyle(
                          color: currentValue == label
                              ? CupertinoDynamicColor.resolve(CupertinoColors.placeholderText, context)
                              : CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                          fontSize:
                              17.0)), // Use systemGrey if it's a placeholder, otherwise black
                ),
                Icon(FeatherIcons.chevronDown,
                    color: CupertinoDynamicColor.resolve(CupertinoColors.label, context)),
              ],
            ),
          ),
        ],
      );  
  }

  void _showCupertinoPicker(BuildContext context, List<String> options,
      String? currentValue, ValueChanged<String>? onSelectedItemChanged) {
    int initialItem = 0;
    if (currentValue != null && options.contains(currentValue)) {
      initialItem = options.indexOf(currentValue);
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            // Button Bar for Done and Cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: Text('Done'),
                  onPressed: () {
                    if (onSelectedItemChanged != null) {
                      onSelectedItemChanged(options[initialItem]);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                backgroundColor: CupertinoColors.white,
                itemExtent: 30,
                scrollController: FixedExtentScrollController(
                  initialItem: initialItem,
                ),
                children: options.map((e) => Text(e)).toList(),
                onSelectedItemChanged: (index) {
                  initialItem = index;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize, FontWeight fontWeight,
      double letterSpacing) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
