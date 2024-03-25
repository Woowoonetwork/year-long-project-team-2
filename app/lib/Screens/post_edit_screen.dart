import 'dart:io';

import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/maps_marker_widget.dart';
import 'package:FoodHood/Models/CreatePostViewModel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'package:FoodHood/Components/upload_image_tile.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum SectionType { date, time }

class EditPostScreen extends StatefulWidget {
  final String postId;
  const EditPostScreen({super.key, required this.postId});
  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen>
    with WidgetsBindingObserver {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController pickupInstrController = TextEditingController();

  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  DateTime selectedTime = DateTime.now().add(Duration(hours: 1));
  List<String> allergensList = [], categoriesList = [];
  List<String> selectedAllergens = [], selectedCategories = [];
  LatLng? selectedLocation;
  Map<String, String> _selectedImagesWithAltText = {};
  CreatePostViewModel viewModel = CreatePostViewModel();
  double _defaultFontSize = 16.0;
  double _textScaleFactor = 1.0;
  double adjustedFontSize = 16.0;
  LatLng? initialLocation;
  GoogleMapController? mapController;
  String instructionText = 'Move the map to select a location';
  late Future<void> _delayFuture;

  @override
  void initState() {
    super.initState();
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
    loadInitialData();
    _delayFuture = Future.delayed(Duration(milliseconds: 300));
    loadPostData(widget.postId);
  }

  Future<void> loadPostData(String postId) async {
    try {
      var postDocument = await FirebaseFirestore.instance
          .collection('post_details')
          .doc(postId)
          .get();

      if (postDocument.exists) {
        var postData = postDocument.data();
        titleController.text = postData?['title'] ?? '';
        descController.text = postData?['description'] ?? '';
        pickupInstrController.text = postData?['pickup_instructions'] ?? '';
        selectedDate = (postData?['expiration_date'] as Timestamp?)?.toDate() ??
            DateTime.now();
        selectedTime = (postData?['pickup_time'] as Timestamp?)?.toDate() ??
            DateTime.now();
        selectedAllergens = postData?['allergens']?.split(', ') ?? [];
        selectedCategories = postData?['categories']?.split(', ') ?? [];
        GeoPoint location = postData?['post_location'];
        selectedLocation = LatLng(location.latitude, location.longitude);

        if (postData?.containsKey('images') == true &&
            postData?['images'] is List) {
          _selectedImagesWithAltText.clear();

          List<dynamic> images = postData!['images'];
          for (var imageMap in images) {
            if (imageMap is Map<String, dynamic>) {
              String url = imageMap['url'] as String? ?? '';
              String altText = imageMap['alt_text'] as String? ?? '';
              if (url.isNotEmpty) {
                _selectedImagesWithAltText[url] = altText;
              }
            }
          }
        } else {
          _selectedImagesWithAltText = {};
        }
      } else {
        print("No such post found");
      }
    } catch (e) {
      print("Error loading post data: $e");
    }
  }

  Future<void> loadInitialData() async {
    try {
      allergensList =
          await viewModel.fetchDocumentData('Allergens', 'allergens');
      categoriesList =
          await viewModel.fetchDocumentData('Categories', 'categories');
      setState(() {});
    } catch (e) {}
  }

  void _updateAdjustedFontSize() {
    adjustedFontSize = _defaultFontSize * _textScaleFactor;
  }

  Future<void> _pickImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: const Text('Choose an option to add a photo from'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImagesWithAltText[image.path] = "";
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        for (var image in images) {
          _selectedImagesWithAltText[image.path] = "";
        }
      });
    }
  }

  Future<void> _savePost() async {
    bool isAnyFieldEmpty = titleController.text.isEmpty ||
        descController.text.isEmpty ||
        pickupInstrController.text.isEmpty;
    bool isNoImageSelected = _selectedImagesWithAltText.isEmpty;
    bool isLocationNotPicked = selectedLocation == null;
    List<String> errorMessages = [];
    if (isAnyFieldEmpty) {
      errorMessages.add("fill in all fields");
    }
    if (isNoImageSelected) {
      errorMessages.add("upload at least one image");
    }
    if (isLocationNotPicked) {
      errorMessages.add("pick a location on the map");
    }

    if (errorMessages.isNotEmpty) {
      String errorMessage =
          "Please " + errorMessages.join(", ") + " before posting.";
      _showErrorDialog(errorMessage);
      return;
    }
    _showLoadingDialog(context, "Saving Post...");

    Map<String, String> updatedImagesWithAltText = {};
    for (var entry in _selectedImagesWithAltText.entries) {
      if (entry.key.startsWith('/')) {
        String? imageUrl = await viewModel.uploadImage(File(entry.key));
        if (imageUrl != null) {
          updatedImagesWithAltText[imageUrl] = entry.value;
        }
      } else {
        updatedImagesWithAltText[entry.key] = entry.value;
      }
    }
    try {
      bool success = await viewModel.updatePost(
        postId: widget.postId,
        title: titleController.text,
        description: descController.text,
        allergens: selectedAllergens,
        categories: selectedCategories,
        expirationDate: selectedDate,
        pickupInstructions: pickupInstrController.text,
        pickupTime: selectedTime,
        postLocation: selectedLocation!,
        imageUrlsWithAltText: updatedImagesWithAltText,
      );

      if (success) {
        _closeLoadingIndicator();
        _showSuccessDialog("Your post has been updated successfully.");
      } else {
        _closeLoadingIndicator();
        _showErrorDialog("Failed to update the post. Please try again.");
      }
    } catch (e) {
      _closeLoadingIndicator();
      _showErrorDialog("An error occurred while saving the post.");
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Oops!"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
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
                  message,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _closeLoadingIndicator() {
    Navigator.pop(context); // Assumes loading dialog is the topmost route
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Optionally close the edit screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: groupedBackgroundColor,
        navigationBar: _buildNavigationBar(context),
        child: SafeArea(
            child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildImageSection(
                    context, _selectedImagesWithAltText.keys.toList()),
                _buildPhotoSection(context),
                buildTextField('Title'),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildTextInputField(
                  context,
                  titleController,
                  'What\'s cooking?',
                  capitalize: true,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildTextField('Description'),
                buildTextInputField(
                  context,
                  descController,
                  'Is there anything special about your dish?',
                  height: 160.0,
                  capitalize: true,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),

                buildDateTimeSection(
                  context: context,
                  sectionType: SectionType.date,
                  selectedDateTime: selectedDate,
                  adjustedFontSize: adjustedFontSize,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildTextField('Allergens'),
                buildCupertinoChipSelection(
                  allergensList,
                  selectedAllergens,
                ),
                buildTextField('Category'),
                buildCupertinoChipSelection(
                  categoriesList,
                  selectedCategories,
                ),
                buildTextField('Pickup Location'),
                buildMapSection(),
                // add an instruction to say "move the map to select a location"
                buildInstructionText(),
                buildDateTimeSection(
                  context: context,
                  sectionType: SectionType.time,
                  selectedDateTime: selectedTime,
                  adjustedFontSize: adjustedFontSize,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildTextInputField(
                  context,
                  pickupInstrController,
                  'Provide pickup instructions here so they can find you',
                  height: 120.0,
                ),
              ],
            ),
          ),
        )));
  }

  SliverToBoxAdapter buildInstructionText() {
    // Assuming instructionText holds the text you want to display
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemBackground, context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            instructionText, // Use the variable that holds the address or default instruction
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: adjustedFontSize - 2, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildCupertinoChipSelection(
    List<String> itemList,
    List<String> selectedItems,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: DottedBorder(
          borderType: BorderType.RRect, // Rounded rectangle border
          radius: Radius.circular(12), // Border corner radius
          padding: EdgeInsets.all(10), // Padding inside the border
          dashPattern: [6, 4], // Pattern of dashes and gaps
          strokeWidth: 2, // Width of the dashes
          color: CupertinoColors.systemGrey
              .withOpacity(0.4), // Color of the dashes
          child: Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: itemList.map((item) {
              final isSelected = selectedItems.contains(item);
              return CupertinoButton(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(item);
                      } else {
                        selectedItems.add(item);
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? blue.resolveFrom(context).withOpacity(0.3)
                            : CupertinoColors.tertiarySystemBackground
                                .resolveFrom(context),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item, // Capitalize the first letter of each word
                            style: TextStyle(
                              color: isSelected
                                  ? MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? darken(blue.resolveFrom(context), 0.4)
                                      : lighten(blue.resolveFrom(context), 0.4)
                                  : CupertinoColors.label.resolveFrom(context),
                              fontSize: adjustedFontSize - 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )));
            }).toList(),
          ),
        ),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor: groupedBackgroundColor,
      middle: Text('Edit Post',
          style:
              _textStyle(CupertinoColors.label.resolveFrom(context)).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          )),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancel',
                style: _textStyle(CupertinoColors.label.resolveFrom(context))
                    .copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _savePost(),
        child: Container(
          child: Text('Save',
              style: _textStyle(CupertinoColors.label.resolveFrom(context))
                  .copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
        ),
      ),
      border: null,
    );
  }

  TextStyle _textStyle(Color color) {
    return TextStyle(
        color: color, fontSize: adjustedFontSize, fontWeight: FontWeight.w600);
  }

  Widget buildImageSection(BuildContext context, List<String> imagePaths) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: imagePaths.isEmpty
            ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)
            : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, // Maintains square aspect ratio for images
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            String imagePath = imagePaths[index];
            return ImageTile(
              imagePath: imagePath,
              onRemove: () {
                setState(() {
                  imagePaths.removeAt(index);
                  _selectedImagesWithAltText.remove(
                      imagePath); // Remove alt text entry for this image
                });
              },
              onAltTextChanged: (altText) {
                setState(() {
                  _selectedImagesWithAltText[imagePath] =
                      altText; // Update alt text for this image
                });
              },
              hasAltText: checkIfImageHasAltText(
                  imagePath), // Implement this method to check if an image has alt text
              altText: getAltTextForImage(imagePath),
            );
          },
        ),
      ),
    );
  }

  String getAltTextForImage(String imagePath) {
    return _selectedImagesWithAltText[imagePath] ?? '';
  }

  bool checkIfImageHasAltText(String imagePath) {
    return _selectedImagesWithAltText[imagePath] != null &&
        _selectedImagesWithAltText[imagePath]!.isNotEmpty;
  }

  Widget _buildPhotoSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CupertinoButton(
          onPressed: () => {_pickImage(), HapticFeedback.selectionClick()},
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              color: blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    size: 28,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? darken(blue.resolveFrom(context), 0.4)
                        : lighten(blue.resolveFrom(context), 0.4)),
                SizedBox(width: 10),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? darken(blue.resolveFrom(context), 0.4)
                        : lighten(blue.resolveFrom(context), 0.4),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.disposeControllers();
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

  SliverToBoxAdapter buildTextField(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 10.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: adjustedFontSize, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildTextInputField(BuildContext context,
      TextEditingController controller, String placeholder,
      {double? height, bool capitalize = false}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 5.0, right: 16.0),
        child: Container(
          height:
              height, // This allows the container to auto-size if height is null.
          child: CupertinoTextField(
            controller: controller,
            maxLines: height != null ? null : 1,
            textAlignVertical: height != null ? TextAlignVertical.top : null,
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            placeholder: placeholder,
            style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize:
                  16, // AdjustedFontSize is not defined in the provided code snippet. Replace 16 with adjustedFontSize or define it.
              fontWeight: FontWeight.w500,
            ),
            placeholderStyle: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.placeholderText, context),
              fontSize: 16, // Same as above regarding adjustedFontSize.
              fontWeight: FontWeight.w500,
            ),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.tertiarySystemBackground, context),
              borderRadius: BorderRadius.circular(16),
            ),
            textCapitalization: capitalize
                ? TextCapitalization.sentences
                : TextCapitalization.none,
          ),
        ),
      ),
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

  SliverToBoxAdapter buildDateTimeSection({
    required BuildContext context,
    required SectionType sectionType,
    required DateTime selectedDateTime,
    required double
        adjustedFontSize, // Ensure this variable is defined and passed
  }) {
    String title =
        sectionType == SectionType.date ? 'Expiration Date' : 'Pickup Time';
    String formattedDateTime = sectionType == SectionType.date
        ? DateFormat('yyyy-MM-dd').format(selectedDateTime)
        : DateFormat('h:mm a').format(selectedDateTime);

    void Function() onTapHandler = () => showPickerModal(
          context,
          isDatePicker: sectionType == SectionType.date,
        );

    EdgeInsets padding = sectionType == SectionType.date
        ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)
        : EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: adjustedFontSize, fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: onTapHandler,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  formattedDateTime,
                  style: TextStyle(
                    fontSize: adjustedFontSize,
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

  void showPickerModal(BuildContext context, {required bool isDatePicker}) {
    DateTime tempSelected = isDatePicker ? selectedDate : selectedTime;
    CupertinoDatePickerMode mode = isDatePicker
        ? CupertinoDatePickerMode.date
        : CupertinoDatePickerMode.time;

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
                    child: Text('Cancel',
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context))),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: Text('Save',
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.label, context))),
                    onPressed: () {
                      if (isDatePicker) {
                        setState(() => selectedDate = tempSelected);
                      } else {
                        setState(() => selectedTime = tempSelected);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: isDatePicker ? selectedDate : selectedTime,
                  onDateTimeChanged: (DateTime newValue) {
                    tempSelected = newValue;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLocationSelected(LatLng location) async {
    String address = await getAddressFromLatLng(location);
    setState(() {
      selectedLocation = location;
      instructionText = address;
    });
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyC9ZK3lbbGSIpFOI_dl-JON4zrBKjMlw2A');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'] != null &&
          jsonResponse['results'].length > 0) {
        String address = jsonResponse['results'][0]['formatted_address'];
        return address;
      } else {
        return 'Location not found';
      }
    } else {
      throw Exception('Failed to fetch address');
    }
  }

  Widget buildMapSection() {
    return FutureBuilder(
      future: _delayFuture, // Use the initialized future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the future to complete, show a loading indicator
          return SliverToBoxAdapter(
            child: Container(
              height: 250.0,
              margin: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: CupertinoActivityIndicator(),
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: Container(
              height: 250.0,
              margin: EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: GoogleMapWidget(
                  initialLocation: selectedLocation,
                  onLocationSelected: _onLocationSelected,
                  isCurrentLocation: false,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
