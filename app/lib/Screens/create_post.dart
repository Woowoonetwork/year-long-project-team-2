import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:FoodHood/Components/search_bar.dart' as CustomSearchBar;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostScreen>
    with WidgetsBindingObserver {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final pickupInstrController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  List<String> allergensList = [],
      categoriesList = [],
      pickupLocationsList = [];
  List<String> selectedAllergens = [],
      selectedCategories = [],
      selectedPickupLocation = [];
  LatLng? selectedLocation;
  String? _mapStyle;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String? _selectedImagePath;

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('centerMarker'),
          position: position,
        ),
      };
    });
  }

  LatLng? initialLocation; // Start with null

  GoogleMapController? mapController; // Controller for the map

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      if (mounted) {
        setState(() {
          initialLocation = LatLng(position.latitude, position.longitude);
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: initialLocation!,
                  zoom: 15.0,
                ),
              ),
            );
          }
        });
      }
    }).catchError((error) {
      // Handle location errors here, such as showing a dialog to the user
      print('Location error: $error');
    });
    fetchData();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName =
          'post_${Uuid().v4()}.jpg'; // Unique file name for the image
      Reference storageRef =
          FirebaseStorage.instance.ref().child('post_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask;
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  final TextEditingController _altTextController = TextEditingController();

  Widget buildImageSection(BuildContext context, String? imagePath) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x01000000),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            margin:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 17.0),
            height: 200,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: imagePath != null
                  ? DecorationImage(
                      image: FileImage(File(imagePath)), fit: BoxFit.cover)
                  : null, // You can put a placeholder image here if you want
            ),
            // If imagePath is null, you might want to show a placeholder or keep it empty
            child: imagePath == null
                ? // fill the container with a color if no image is selected
                Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.secondarySystemFill
                          .resolveFrom(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: // an icon with text
                        Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Click "+" to add photo',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context))),
                      ],
                    ),
                  )
                : null, // No child needed if the image is displayed
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photo',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 5),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => pickImage(context),
                      child: Container(
                        width: 76,
                        height: 74,
                        decoration: BoxDecoration(
                            color: accentColor.resolveFrom(context),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(FeatherIcons.plus,
                            size: 37, color: CupertinoColors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Alt Text Title and Field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alt Text',
                        style: TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 74,
                        child: CupertinoTextField(
                          controller: _altTextController,
                          placeholder: 'No Alt Text Added',
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.center,
                          padding: EdgeInsets.all(16.0),
                          style: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.label, context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          placeholderStyle: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.placeholderText, context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          decoration: BoxDecoration(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.tertiarySystemBackground,
                                  context),
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
        _selectedImagePath = image.path;
      });

      // Upload image and get URL
      String? imageUrl =
          await _uploadImageToFirebase(File(_selectedImagePath!));

      if (imageUrl != null) {
        // Do something with the uploaded image URL
        print("Image uploaded: $imageUrl");
      } else {
        // Handle upload failure
        print("Failed to upload image.");
      }

      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    pickupInstrController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await fetchDocumentData('Allergens', 'allergens');
    await fetchDocumentData('Categories', 'categories');
    await fetchDocumentData('Pickup Locations', 'items');
  }

  Future<void> fetchDocumentData(String docName, String fieldName) async {
    try {
      var data = await readDocument(collectionName: 'Data', docName: docName);
      if (data != null && data.containsKey(fieldName)) {
        List<String> fetchedData =
            List<String>.from(data[fieldName].cast<String>());
        setState(() {
          if (docName == 'Allergens') {
            allergensList = fetchedData;
          } else if (docName == 'Categories') {
            categoriesList = fetchedData;
          } else if (docName == 'Pickup Locations') {
            pickupLocationsList = fetchedData;
          }
        });
      } else {
        print('$docName document or $fieldName field not found.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAndUpdateMapStyle();
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            buildSliverNavigationBar(context),
          ];
        },
        body: CustomScrollView(
          slivers: <Widget>[
            buildImageSection(context, _selectedImagePath),
            SliverToBoxAdapter(child: SizedBox(height: 30.0)),
            buildTextField('Title'),
            buildTextInputField(titleController, ''),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildTextField('Description'),
            buildLargeTextInputField(descController, ''),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildTextField('Allergens'),
            buildSearchBar(allergensList, selectedAllergens),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildExpireDateSection(),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildTextField('Category'),
            buildSearchBar(categoriesList, selectedCategories),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildTextField('Pickup Location'),
            buildSearchBar(pickupLocationsList, selectedPickupLocation),
            buildMapSection(),
            SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            buildTextField('Pickup Instructions'),
            buildLargeTextInputField(
              pickupInstrController,
              '',
            ),
            buildTimeSection(),
            SliverToBoxAdapter(child: SizedBox(height: 40.0)),
          ],
        ),
      ),
    );
  }

  // Add this method to your class
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
                    fontSize: 16,
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

  CupertinoSliverNavigationBar buildSliverNavigationBar(BuildContext context) {
    return CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor: groupedBackgroundColor,
      largeTitle:
          Text('New Post', style: TextStyle(fontWeight: FontWeight.w600)),
      leading: GestureDetector(
        child: Icon(FeatherIcons.x,
            color: CupertinoColors.label.resolveFrom(context), size: 24.0),
        onTap: () async => await showConfirmationDialog(context)
            ? Navigator.of(context).pop()
            : null,
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('Save',
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w600)),
        onPressed: () => savePost(context),
      ),
      border: const Border(bottom: BorderSide.none),
    );
  }

  void savePost(BuildContext context) async {
  if ([titleController.text, descController.text, pickupInstrController.text]
          .any((element) => element.isEmpty) ||
      [selectedAllergens, selectedCategories, selectedPickupLocation]
          .any((list) => list.isEmpty)) {
    showEmptyFieldsAlert(context);
    return;
  }

  showLoadingDialog(context, loadingMessage: 'Saving Post...'); // Show loading indicator

  String? imageUrl;
  if (_selectedImagePath != null) {
    imageUrl = await _uploadImageToFirebase(File(_selectedImagePath!));
    if (imageUrl == null) {
      print("Image upload failed");
      Navigator.of(context).pop(); // Close the loading dialog
      // Optionally show an error message to the user
      return;
    }
  }

  // Continue with saving the post details including imageUrl if available
  try {
    final user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'default uid';
    String documentId = Uuid().v4();

    await FirebaseFirestore.instance
        .collection('post_details')
        .doc(documentId)
        .set({
      'title': titleController.text,
      'description': descController.text,
      'allergens': selectedAllergens.join(', '),
      'categories': selectedCategories.join(', '),
      'expiration_date': Timestamp.fromDate(selectedDate),
      'pickup_location': selectedPickupLocation.join(', '),
      'pickup_instructions': pickupInstrController.text,
      'pickup_time': Timestamp.fromDate(selectedTime),
      'user_id': userId,
      'post_location':
          GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
      'post_timestamp': FieldValue.serverTimestamp(),
      'image_url': imageUrl ?? '', // Add image URL to the document
    });

    Navigator.of(context).pop(); // Close the loading dialog

    // Success callback or navigate the user away from the current screen
    Navigator.of(context).pop(); // Pop the current screen to go back

    // Show a confirmation dialog on the previous screen
    showPostSavedConfirmation(context);
  } catch (e) {
    print("Error saving post: $e");
    Navigator.of(context).pop(); // Close the loading dialog
    // Optionally handle the error, e.g., by showing an error message to the user
  }
}

void showPostSavedConfirmation(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Post Published'),
        content: Text('Your post has been published successfully.'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Hooraay!'),
          ),
        ],
      );
    },
  );
}


  SliverToBoxAdapter buildTextField(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 17.0, top: 10.0),
        child: Text(text,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
      ),
    );
  }

  SliverToBoxAdapter buildTextInputField(
      TextEditingController controller, String placeholder) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0),
        child: CupertinoTextField(
          controller: controller,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          placeholder: placeholder,
          style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: 16,
              fontWeight: FontWeight.w500),
          placeholderStyle: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.placeholderText, context),
              fontSize: 16,
              fontWeight: FontWeight.w500),
          decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.tertiarySystemBackground, context),
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildLargeTextInputField(
      TextEditingController controller, String placeholder) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0),
      child: Container(
        height: 180,
        child: CupertinoTextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.top,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          placeholder: placeholder,
          style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: 16,
              fontWeight: FontWeight.w500),
          placeholderStyle: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.placeholderText, context),
              fontSize: 16,
              fontWeight: FontWeight.w500),
          decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.tertiarySystemBackground, context),
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ));
  }

  SliverToBoxAdapter buildSearchBar(
      List<String> itemList, List<String> selectedItems) {
    return SliverToBoxAdapter(
      child: CustomSearchBar.SearchBar(
          itemList: itemList,
          onItemsSelected: (List<String> items) {
            setState(() {
              if (itemList == allergensList) {
                selectedAllergens = items;
              } else if (itemList == categoriesList) {
                selectedCategories = items;
              } else if (itemList == pickupLocationsList) {
                selectedPickupLocation = items;
              }
            });
          }),
    );
  }

  SliverToBoxAdapter buildDateSection(
      DateTime selectedDate, Function(BuildContext) showPicker) {
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate); // Format the date
    return SliverToBoxAdapter(
      child: CupertinoButton(
        onPressed: () => showPicker(context),
        child: Text(formattedDate),
      ),
    );
  }

  SliverToBoxAdapter buildExpireDateSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 17.0, right: 17.0, top: 16.0, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Expiration Date',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () => showDatePickerModal(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter buildTimeSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        padding: EdgeInsets.only(left: 17.0, right: 12.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pickup Time',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () => showTimePickerModal(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: Text(
                  DateFormat('h:mm a').format(selectedTime),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDatePickerModal(BuildContext context) {
    DateTime tempSelectedDate =
        selectedDate; // Temporary variable to hold the new date selection

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
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
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label, context),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDate =
                            tempSelectedDate; // Update the state with the new date
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              // Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    tempSelectedDate =
                        newDate; // Update tempSelectedDate with the new selection
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool? result = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Discard Draft?'),
          content: Text('Are you sure you want to discard your changes?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(
                    context, false); // User does not want to discard changes
              },
            ),
            CupertinoDialogAction(
              child: Text('Discard'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(
                    context, true); // User confirms to discard changes
              },
            ),
          ],
        );
      },
    );
    return result ?? false; // Default to false if result is null
  }

  void showTimePickerModal(BuildContext context) {
    DateTime tempSelectedTime =
        selectedTime; // Temporary variable to hold the new time selection

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
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
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label, context),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedTime =
                            tempSelectedTime; // Update the state with the new time
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              // Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedTime,
                  onDateTimeChanged: (DateTime newTime) {
                    tempSelectedTime =
                        newTime; // Update tempSelectedTime with the new selection
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter buildMapSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 250.0, // Adjust the height as needed
        margin: EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0), // Apply corner radius
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _onMapCreated(controller);
                  if (selectedLocation != null) {
                    _updateMarker(selectedLocation!);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: selectedLocation ??
                      LatLng(37.7749, -122.4194), // Default or user location
                  zoom: 12.0,
                ),
                onCameraMove: (CameraPosition position) {
                  selectedLocation =
                      position.target; // Update location on map pan
                  _updateMarker(position.target);
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer()),
                },
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    onPressed: _goToMyLocation,
                    color: CupertinoColors.tertiarySystemBackground,
                    borderRadius: BorderRadius.circular(100.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                    child: Icon(CupertinoIcons.location_fill,
                        size: 18, color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  void _goToMyLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng myLocation = LatLng(position.latitude, position.longitude);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 14));
    setState(() {
      selectedLocation = myLocation;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(_mapStyle);
    // If initialLocation is already set, immediately move the camera to that position
    if (initialLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: initialLocation!,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _checkAndUpdateMapStyle() async {
    String stylePath =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? 'assets/map_style_dark.json'
            : 'assets/map_style_light.json';
    String style = await rootBundle.loadString(stylePath);
    if (_mapStyle != style) {
      setState(() => _mapStyle = style);
      mapController?.setMapStyle(_mapStyle);
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _checkAndUpdateMapStyle();
  }

  void showEmptyFieldsAlert(BuildContext context) {
    // find which field is empty
    String emptyField = '';

    if (titleController.text.isEmpty) {
      emptyField = 'Title';
    } else if (descController.text.isEmpty) {
      emptyField = 'Description';
    } else if (pickupInstrController.text.isEmpty) {
      emptyField = 'Pickup Instructions';
    } else if (selectedAllergens.isEmpty) {
      emptyField = 'Allergens';
    } else if (selectedCategories.isEmpty) {
      emptyField = 'Categories';
    } else if (selectedPickupLocation.isEmpty) {
      emptyField = 'Pickup Location';
    }
    print(emptyField);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Missing Information'),
          content: Text('Please enter all the information before saving.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
