import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/googleMapsWidget.dart';
import 'package:FoodHood/Models/CreatePostViewModel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:FoodHood/Components/search_bar.dart' as CustomSearchBar;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'package:FoodHood/Components/imageTile.dart';

enum SectionType { date, time }

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostScreen>
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

  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      final text = titleController.text;
      titleController.value = titleController.value.copyWith(
        text: text.capitalize(),
        selection: TextSelection.collapsed(offset: text.length),
      );
    });

    descController.addListener(() {
      final text = descController.text;
      descController.value = descController.value.copyWith(
        text: text.capitalize(),
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
    setInitialLocation();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      allergensList =
          await viewModel.fetchDocumentData('Allergens', 'allergens');
      categoriesList =
          await viewModel.fetchDocumentData('Categories', 'categories');
      setState(
          () {}); // Call setState to update the UI after the data is fetched
    } catch (e) {
      // Handle any errors here
    }
  }

  void _updateAdjustedFontSize() {
    adjustedFontSize = _defaultFontSize * _textScaleFactor;
  }

  Future<void> setInitialLocation() async {
    Position position = await viewModel.determinePosition();
    setState(
        () => initialLocation = LatLng(position.latitude, position.longitude));
  }

  void _updateMarker(LatLng position) {}

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        for (var image in images) {
          _selectedImagesWithAltText[image.path] =
              ""; // Initialize alt text with an empty string
        }
      });
    }
  }

  Future<void> _savePost() async {
    // Only checking if title, description, and pickup instructions are empty
    bool isAnyFieldEmpty = titleController.text.isEmpty ||
        descController.text.isEmpty ||
        pickupInstrController.text.isEmpty;

    // Checking if no images are selected
    bool isNoImageSelected = _selectedImagesWithAltText.isEmpty;

    // Check if a location has been picked
    bool isLocationNotPicked = selectedLocation == null;

    // Combine all error messages into one to display in the dialog
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
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Oops! Something's missing"),
          content: Text(errorMessage),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

// Start loading
    showLoadingDialog(context); // Show loading indicator

    try {
      List<File> imageFiles =
          _selectedImagesWithAltText.keys.map((path) => File(path)).toList();

      Map<String, String> imageUrlsWithPaths =
          await viewModel.uploadImagesToFirebase(imageFiles);

      // The alt text is no longer mandatory, so provide a default empty string if it's missing
      Map<String, String> imageUrlsWithAltText = imageUrlsWithPaths.map(
          (url, path) => MapEntry(url, _selectedImagesWithAltText[path] ?? ""));

      bool success = await viewModel.savePost(
        title: titleController.text,
        description: descController.text,
        allergens: selectedAllergens,
        categories: selectedCategories,
        expirationDate: selectedDate,
        pickupInstructions: pickupInstrController.text,
        pickupTime: selectedTime,
        postLocation: selectedLocation!,
        imageUrlsWithAltText: imageUrlsWithAltText,
      );
      if (success) {
        if (mounted) {
          Navigator.pop(context); // Close loading indicator
        }
        Navigator.pop(context); // Close the create post screen
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Post published"),
            content: Text("Your post has been posted successfully."),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("An error occurred while saving the post."),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
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
                SliverToBoxAdapter(child: SizedBox(height: 20.0)),
                buildTextField('Title'),
                buildTextInputField(
                    context, titleController, 'What\'s cooking?'),
                SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                buildTextField('Description'),
                buildTextInputField(context, descController,
                    'Is there anything special about your dish?',
                    height: 160.0),
                buildImageSection(
                    context, _selectedImagesWithAltText.keys.toList()),
                _buildPhotoSection(context),
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
          color: CupertinoColors.systemGrey, // Color of the dashes
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
                            ? accentColor.resolveFrom(context)
                            : CupertinoColors.tertiarySystemBackground
                                .resolveFrom(context),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.capitalize(), // Capitalize the first letter of each word
                            style: TextStyle(
                              color: isSelected
                                  ? CupertinoColors.white
                                  : CupertinoColors.label.resolveFrom(context),
                              fontSize:
                                  adjustedFontSize, // Ensure this variable is defined and passed
                              fontWeight: FontWeight.w500,
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
      middle: Text('New Post',
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _savePost(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
              color: accentColor, borderRadius: BorderRadius.circular(100.0)),
          child: Text('Post', style: _textStyle(CupertinoColors.white)),
        ),
      ),
      border: const Border(bottom: BorderSide.none),
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
          onPressed: () => _pickImage(),
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 28,
                  color: CupertinoColors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    color: CupertinoColors.white,
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
      {double? height}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 5.0, right: 16.0),
        child: Container(
          height:
              height, // This will be null by default, allowing the container to auto-size.
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
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildSearchBar(
      List<String> itemList, List<String> selectedItems) {
    return SliverToBoxAdapter(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: DottedBorder(
        borderType: BorderType.RRect, // Rounded rectangle border
        radius: Radius.circular(12), // Border corner radius
        padding: EdgeInsets.all(4), // Padding inside the border
        dashPattern: [6, 4], // Pattern of dashes and gaps
        strokeWidth: 2, // Width of the dashes
        color: Colors.grey, // Color of the dashes
        child: CustomSearchBar.SearchBar(
            itemList: itemList,
            onItemsSelected: (List<String> items) {
              setState(() {
                if (itemList == allergensList) {
                  selectedAllergens = items;
                } else if (itemList == categoriesList) {
                  selectedCategories = items;
                }
              });
            }),
      ),
    ));
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
                    child: Text('Done',
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

  void _onLocationSelected(LatLng location) {
    setState(() {
      selectedLocation =
          location; // This updates the selectedLocation with the new position from the map
    });
  }

  Widget buildMapSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 250.0,
        margin: EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: GoogleMapWidget(
            initialLocation: initialLocation, // Make sure this is not null
            onLocationSelected:
                _onLocationSelected, // Here you listen for changes
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(' ');
  }
}
