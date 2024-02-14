import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';

const double _defaultFontSize = 16.0;

class EditProfilePage extends StatefulWidget {
  final Function? onProfileUpdated;

  EditProfilePage({this.onProfileUpdated});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _profileImagePath = '';
  List<String> _provinces = [];
  Map<String, List<String>> _cities = {};
  String _selectedProvince = '';
  String _selectedCity = '';
  bool _isLoading = false;
  late double adjustedFontSize;
  late double _textScaleFactor;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _textScaleFactor = Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
  }

  void _updateAdjustedFontSize() {
    adjustedFontSize = _defaultFontSize * _textScaleFactor;
  }

  void _fetchProvincesAndCities() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('location')
          .doc('rLxaYnbNB4x6Rpvil1Oe')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.get('location');
        Map<String, List<String>> fetchedCities = {};

        data.forEach((province, citiesList) {
          if (citiesList is List) {
            fetchedCities[province] = List<String>.from(citiesList);
          }
        });

        if (fetchedCities.isNotEmpty) {
          setState(() {
            _provinces = fetchedCities.keys.toList();
            _cities = fetchedCities;
            // Set the selected province and city firebase record,
            // if none, set to the first available options
            _selectedProvince = _selectedProvince.isNotEmpty
                ? _selectedProvince
                : _provinces.first;
            _selectedCity = _selectedCity.isNotEmpty
                ? _selectedCity
                : _cities[_selectedProvince]!.first;
          });
        }
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          // Check mounted before calling setState
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _firstNameController.text = data['firstName'] ?? '';
            _lastNameController.text = data['lastName'] ?? '';
            _aboutMeController.text = data['aboutMe'] ?? '';
            _emailController.text = user.email ?? data['email'] ?? '';
            _selectedProvince = data['province'] ?? _selectedProvince;
            _selectedCity = data['city'] ?? _selectedCity;
            _profileImagePath = data['profileImagePath'] ?? _profileImagePath;
            _isLoading = false;
            _fetchProvincesAndCities();
          });
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

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
      backgroundColor: groupedBackgroundColor,
      navigationBar: buildNavigationBar(context),
      child: _isLoading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CupertinoActivityIndicator(),
                  SizedBox(height: 8),
                  Text('Uploading Profile Image...',
                      style: TextStyle(color: CupertinoColors.label)),
                ]))
          : SafeArea(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: _buildProfileForm(context))),
    );
  }

  ObstructingPreferredSizeWidget buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(FeatherIcons.x,
              size: 22,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.label, context))),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('Save',
          style: TextStyle(
            color: accentColor, 
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () async {
          VoidCallback onComplete = () => Navigator.of(context).pop('updated');
          await _updateUserProfile(onComplete);
        },
      ),
      backgroundColor: groupedBackgroundColor,
      border: null,
      transitionBetweenRoutes: false,
    );
  }

  Future<void> _updateUserProfile([VoidCallback? onComplete]) async {
    // Validation for required fields
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedProvince.isEmpty ||
        _selectedCity.isEmpty) {
      _showDialog(context, "Complete all fields",
          "All information are required to update profile.");
      return;
    }

    // Show loading dialog
    showLoadingDialog(context, loadingMessage: 'Updating');

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Map<String, dynamic> updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'aboutMe': _aboutMeController.text,
        'email': _emailController.text,
        'province': _selectedProvince,
        'city': _selectedCity,
        'profileImagePath': _profileImagePath,
      };

      // Update the user's profile in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .update(updateData);
      print("Profile updated successfully");

      if (onComplete != null) onComplete();
      widget.onProfileUpdated?.call();

      // Dismiss loading dialog
      Navigator.of(context).pop(); // Close the loading dialog
    } catch (e) {
      print("Error updating profile: $e");
      Navigator.of(context)
          .pop(); // Ensure the loading dialog is closed on error
      _showDialog(
          context, "Error", "Failed to update profile. Please try again.");
    }
  }

  void showLoadingDialog(BuildContext context,
      {String loadingMessage = 'Loading'}) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 24),
                Text(
                  loadingMessage, // Customizable message
                  style: TextStyle(
                    fontSize: adjustedFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = 'profile_$userId.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Widget _buildProfileForm(BuildContext context) {
    return Column(children: <Widget>[
      _buildProfileImageUploader(context),
      Row(children: <Widget>[
        Expanded(
            child: _buildTextField(
                'First Name', 'First Name', _firstNameController, context)),
        Expanded(
            child: _buildTextField(
                'Last Name', 'Last Name', _lastNameController, context)),
      ]),
      _buildLargeTextField('About Me', _aboutMeController, context),
      _buildTextField('Email', 'Enter Email here', _emailController, context),
      Row(children: <Widget>[
        Expanded(
            child: _buildPickerField(
                context, 'Province', _selectedProvince, _provinces,
                (String newValue) {
          setState(() {
            _selectedProvince = newValue;
            _selectedCity = _cities[_selectedProvince]?.first ?? '';
          });
        })),
        Expanded(
            child: _buildPickerField(context, 'City', _selectedCity,
                _cities[_selectedProvince] ?? [], (String newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        })),
      ]),
    ]);
  }

  Widget _buildProfileImageUploader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: CupertinoColors
                    .tertiarySystemFill, // Background color for loading state
                image: _isLoading
                    ? null
                    : DecorationImage(
                        // Conditional image loading
                        image: _getProfileImage(),
                        fit: BoxFit.cover,
                      ),
              ),
              child: _isLoading
                  ? Center(
                      child:
                          CupertinoActivityIndicator()) // Show loading indicator if loading
                  : null, // No additional content if not loading
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
                      Center(
                        child: Icon(
                          FeatherIcons.uploadCloud,
                          size: 22,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label, context),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upload Profile Picture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: adjustedFontSize,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.label, context),
                            letterSpacing: -0.60,
                            fontWeight: FontWeight.w500
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  await _uploadImage();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImagePath.isNotEmpty) {
      // Check if the path is a local file path
      if (Uri.parse(_profileImagePath).scheme == 'file') {
        // Use FileImage for local file paths
        return FileImage(File(_profileImagePath));
      } else {
        // Assuming _profileImagePath is a URL to a network image
        return CachedNetworkImageProvider(_profileImagePath);
      }
    }
    // Fallback to a local asset image if the network image URL or local file path is empty
    return AssetImage("assets/images/sampleProfile.png");
  }

  Widget _buildTextField(String label, String placeholder,
      TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: adjustedFontSize,
              letterSpacing: -0.40,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            padding: EdgeInsets.all(16.0),
            placeholder: placeholder,
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: adjustedFontSize,
              fontWeight: FontWeight.w500
            ),
            placeholderStyle: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.placeholderText, context),
              fontSize: adjustedFontSize,
              fontWeight: FontWeight.w500
            ),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.tertiarySystemBackground, context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextField(
      String label, TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: -0.60,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.label, context),
              fontSize: adjustedFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 180,
            child: CupertinoTextField(
              controller: controller,
              padding: EdgeInsets.all(16.0),
              placeholder: 'No Bio Provided',
              placeholderStyle: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.placeholderText, context),
                fontSize: adjustedFontSize,
                fontWeight: FontWeight.w500,
              ),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context),
                borderRadius: BorderRadius.circular(12),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                fontSize: adjustedFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField(
      BuildContext context,
      String label,
      String currentValue,
      List<String> options,
      ValueChanged<String> onSelectedItemChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: -0.60,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.label, context),
              fontSize: adjustedFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.all(16),
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemBackground, context),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => _showCupertinoPicker(
                context, options, currentValue, onSelectedItemChanged),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      currentValue,
                      style: TextStyle(
                        color: currentValue == label
                            ? CupertinoDynamicColor.resolve(
                                CupertinoColors.placeholderText, context)
                            : CupertinoDynamicColor.resolve(
                                CupertinoColors.label, context),
                        fontSize: adjustedFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ),
                Icon(FeatherIcons.chevronDown,
                    size: 18,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.label, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoPicker(BuildContext context, List<String> options,
      String currentValue, ValueChanged<String> onSelectedItemChanged) {
    int initialItem = options.indexOf(currentValue);
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.tertiarySystemBackground, context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, context),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: Text('Done',
                      style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label, context),
                      )),
                  onPressed: () {
                    onSelectedItemChanged(options[initialItem]);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                backgroundColor: CupertinoColors.tertiarySystemBackground,
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

  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return; // Add this check before calling setState
      setState(() {
        _isLoading = true; // Show loading indicator while uploading
      });

      // Call _uploadImageToFirebase and pass the selected image file
      String? imageUrl = await _uploadImageToFirebase(File(image.path));

      if (!mounted) return; // Add this check again before calling setState
      setState(() {
        _profileImagePath = imageUrl ?? _profileImagePath;
        _isLoading = false; // Hide loading indicator after uploading
      });
    } else {
      print("Image selection canceled");
    }
  }
}
