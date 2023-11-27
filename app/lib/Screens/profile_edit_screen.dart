import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import Dart's IO library to use File
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedProvince = 'BC';
  String _selectedCity = 'Kelowna';
  String?  _profileImagePath; // New variable to store the path of the selected profile image

  @override
  void initState() {
    super.initState();
    fetchProvincesAndCities();
  }

  void fetchProvincesAndCities() async {
  FirebaseFirestore.instance.collection('location').doc('rLxaYnbNB4x6Rpvil1Oe').get().then((documentSnapshot) {
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



  List<String> provinces = []; // Updated to be fetched from Firestore
  Map<String, List<String>> cities = {}; // Updated to be fetched from Firestore

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aboutMeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: _buildNavigationBar(context),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: _buildProfileForm(context),
        ),
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(FeatherIcons.x, size: 22, color: CupertinoColors.label)),
      trailing: Text(
        'Save',
        style: TextStyle(color: Color(0xFF337586), fontWeight: FontWeight.w500),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      border: Border(),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildProfileImageUploader(context),

        Row(
          children: <Widget>[
            Expanded(
              child:
                  _buildTextField('First Name', 'First Name', _firstNameController),
            ),
            Expanded(
              child: _buildTextField('Last Name', 'Last Name', _lastNameController),
            ),
          ],
        ),
        // ... The rest of your widgets go here

        _buildLargeTextField('About Me', _aboutMeController),
        _buildTextField('Email', 'Enter Email here', _emailController),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildPickerField(
                context,
                'Province',
                _selectedProvince,
                provinces,
                (String newValue) {
                  setState(() {
                    _selectedProvince = newValue;
                    _selectedCity = cities[_selectedProvince]?.first ?? '';
                  });
                },
              ),
            ),
            Expanded(
              child: _buildPickerField(
                context,
                'City',
                _selectedCity,
                cities[_selectedProvince] ?? [],
                (String newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildActionButtons(
            'Reset Password',
            CupertinoColors.activeBlue,
            () => _showActionSheet(context, 'Reset Password'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActionButtons(
            'Delete Account',
            CupertinoColors.destructiveRed,
            () => _showActionSheet(context, 'Delete Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageUploader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                image: DecorationImage(
                  // Use FileImage if an image has been picked, otherwise use AssetImage
                  image: _profileImagePath != null
                      ? FileImage(
                          File(_profileImagePath!)) // Cast the path to a File
                      : AssetImage("assets/images/sampleProfile.png")
                          as ImageProvider, // Explicitly cast AssetImage to ImageProvider
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CupertinoButton(
                color: CupertinoColors.tertiarySystemBackground,
                padding: EdgeInsets.zero,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FeatherIcons.uploadCloud,
                          size: 22, color: CupertinoColors.label),
                      SizedBox(width: 8),
                      Text(
                        'Upload Profile Picture',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                          letterSpacing: -.80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  // Use ImagePicker to let the user select an image
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    // Update the UI or do something with the selected image
                    setState(() {
                      // For example, you could save the path of the selected image
                      // and use it somewhere in your app
                      // _selectedImagePath = image.path;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: CupertinoColors.black,
                  letterSpacing: -1.0,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Container(
            height: 54,
            child: CupertinoTextField(
              controller: controller,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              placeholder: placeholder,
              placeholderStyle: TextStyle(
                color: CupertinoColors.systemGrey, // Placeholder text color
                fontSize:
                    17.0, // Match the default font size of CupertinoTextField
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: -1.0,
              color: CupertinoColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 180, // Fixed height for the container
            child: CupertinoTextField(
              controller: controller,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              placeholder: 'No Bio Provided', // Placeholder text
              placeholderStyle: TextStyle(
                color: CupertinoColors.systemGrey,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(
                color: CupertinoColors.black, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      String title, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        width: double.infinity, // Makes the button take full width
        child: CupertinoButton(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          onPressed: onPressed,
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerField(
      BuildContext context,
      String label,
      String currentValue,
      List<String> options,
      ValueChanged<String> onSelectedItemChanged) {
    // Determine if the current value is a valid selection or should be treated as placeholder text
    bool isPlaceholder =
        currentValue.isEmpty || !options.contains(currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: CupertinoColors.black,
                  letterSpacing: -1.0,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.all(12),
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            onPressed: () => _showCupertinoPicker(
                context, options, currentValue, onSelectedItemChanged),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(currentValue,
                      style: TextStyle(
                          color: isPlaceholder
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.black,
                          fontSize:
                              17.0)), // Use systemGrey if it's a placeholder, otherwise black
                ),
                Icon(FeatherIcons.chevronDown,
                    color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        ],
      ),
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

  void _showActionSheet(BuildContext context, String action) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          '$action',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: CupertinoColors.secondaryLabel,
            fontSize: 16,
            letterSpacing: -0.41,
          ),
        ),
        message: Text(
            'Are you sure you want to $action?'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              'Confirm',
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.41,
              ),
            ),
            onPressed: () {
              // Handle the action
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path; // Update the profile image path
      });
    }
  }
}
