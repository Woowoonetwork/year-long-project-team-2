
import 'dart:io';
import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 

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
  String firstName = '';
  String lastName = '';
  String aboutMe = '';
  String email = '';
  String selectedProvince = '';
  String selectedCity = '';
  String profileImagePath =
      ''; // Variable to store the path of the selected profile image
  bool isLoading = false; // Initialize as false
  bool _isImageChanged = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchProvincesAndCities();
  }

  void fetchProvincesAndCities() async {
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
            provinces = fetchedCities.keys.toList();
            cities = fetchedCities;
            selectedProvince ??= provinces.first;
            selectedCity ??= cities[selectedProvince]?.first ?? '';
          });
        }
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void fetchUserDetails() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _aboutMeController.text = data['aboutMe'] ?? '';
          _emailController.text = user.email ?? data['email'] ?? '';

          setState(() {
            selectedProvince = data['province'] ?? selectedProvince;
            selectedCity = data['city'] ?? selectedCity;
            profileImagePath = data['profileImagePath'] ?? profileImagePath;
          });
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }

    setState(() => isLoading = false);
  }

  List<String> provinces = [];
  Map<String, List<String>> cities = {};

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
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: buildProfileForm(context),
              ),
            ),
    );
  }

  ObstructingPreferredSizeWidget buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(FeatherIcons.x,
            size: 22,
            color:
                CupertinoDynamicColor.resolve(CupertinoColors.label, context)),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          'Save',
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          // Define what onComplete should do
          VoidCallback onComplete = () => Navigator.of(context)
              .pop('updated'); // Pop with a result if needed

          // Call _updateUserProfile and pass onComplete
          _updateUserProfile(profileImagePath, onComplete);
        },
      ),
      backgroundColor: groupedBackgroundColor,
      border: Border(),
    );
  }

  void _updateUserProfile([String? imageUrl, VoidCallback? onComplete]) async {
print("dadada $imageUrl");
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Create a map of data to update
      Map<String, dynamic> updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'aboutMe': _aboutMeController.text,
        'email': _emailController.text,
        'province': selectedProvince,
        'city': selectedCity,
      };

String stringImageUrl = imageUrl ?? '';
print("babababa $stringImageUrl");

      // Only update the profile image if a new image was selected
      if (stringImageUrl != '') {
        imageUrl = await _uploadImageToFirebase(File(stringImageUrl));
        updateData['profileImagePath'] = imageUrl;
      }

      // Update the user's profile in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .update(updateData);
      print("Profile updated successfully");

      // If an onComplete callback is provided, call it
      if (onComplete != null) {
        onComplete();
      }
      widget.onProfileUpdated?.call();
    } catch (e) {
      print("Error updating profile: $e");
    }
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
      print(downloadUrl);
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Widget buildProfileForm(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildProfileImageUploader(context),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTextField(
                  'First Name', 'First Name', _firstNameController),
            ),
            Expanded(
              child: _buildTextField(
                  'Last Name', 'Last Name', _lastNameController),
            ),
          ],
        ),
        _buildLargeTextField('About Me', _aboutMeController),
        _buildTextField('Email', 'Enter Email here', _emailController),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildPickerField(
                context,
                'Province',
                selectedProvince,
                provinces,
                (String newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    selectedCity = cities[selectedProvince]?.first ?? '';
                  });
                },
              ),
            ),
            Expanded(
              child: _buildPickerField(
                context,
                'City',
                selectedCity,
                cities[selectedProvince] ?? [],
                (String newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
              ),
            ),
          ],
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
                  image: profileImagePath != ''
                      ? FileImage(
                          File(profileImagePath!)) // Cast the path to a File
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
                          size: 22,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label, context)),
                      SizedBox(width: 8),
                      Text(
                        'Upload Profile Picture',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label, context),
                          letterSpacing: -.80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  // Use ImagePicker to let the user select an image
                      await _uploadImage();
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
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.label, context),
                  letterSpacing: -0.80,
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
                color: CupertinoColors.tertiarySystemBackground,
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
              letterSpacing: -0.80,
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
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
                color: CupertinoColors.label.resolveFrom(context),
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(
                color:CupertinoColors.label.resolveFrom(context),
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
    bool isPlaceholder =
        currentValue.isEmpty || !options.contains(currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.label, context),
                  letterSpacing: -0.80,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.all(12),
            color: CupertinoColors.tertiarySystemBackground,
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
                              ? CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context)
                              : CupertinoDynamicColor.resolve(
                                  CupertinoColors.label, context),
                          fontSize:
                              17.0)), 
                ),
                Icon(FeatherIcons.chevronDown,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.secondaryLabel, context)),
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
            letterSpacing: -0.80,
          ),
        ),
        message: Text('Are you sure you want to $action?'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              'Confirm',
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.80,
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

  Future <void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImagePath = image.path;
print("cacacaca $profileImagePath");
      });
    }
else{print("image selection canceled");}
  }
}
