// create_post.dart
// a page that allows users to create a new post
import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import '../firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:FoodHood/Components/search_bar.dart' as CustomSearchBar;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostScreen> {
  List<String> allergensList = [];
  List<String> categoriesList = [];
  List<String> pickupLocationsList = [];

  // Add method to show date picker in a modal popup
  void showDatePickerModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = newDate;
              });
            },
          ),
        );
      },
    );
  }

  // Add method to show time picker in a modal popup
  void showTimePickerModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: selectedTime,
            onDateTimeChanged: (DateTime newTime) {
              setState(() {
                selectedTime = newTime;
              });
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      Map<String, dynamic>? allergensData = await readDocument(
        collectionName: 'Data',
        docName: 'Allergens',
      );

      if (allergensData != null && allergensData.containsKey('allergens')) {
        List<dynamic> allergensListData = allergensData['allergens'];
        setState(() {
          allergensList = List<String>.from(allergensListData.cast<String>());
        });
      } else {
        print('Allergens document or allergens field not found.');
      }

      // Fetch categories data
      Map<String, dynamic>? categoriesData = await readDocument(
        collectionName: 'Data',
        docName: 'Categories',
      );

      if (categoriesData != null && categoriesData.containsKey('categories')) {
        List<dynamic> categoriesListData = categoriesData['categories'];
        setState(() {
          categoriesList = List<String>.from(categoriesListData.cast<String>());
        });
      } else {
        print('Categories document or categories field not found.');
      }

      // Fetch pickup locations data
      Map<String, dynamic>? pickupLocationsData = await readDocument(
        collectionName: 'Data',
        docName: 'Pickup Locations',
      );

      if (pickupLocationsData != null &&
          pickupLocationsData.containsKey('items')) {
        List<dynamic> pickupLocationsListData = pickupLocationsData['items'];
        setState(() {
          pickupLocationsList =
              List<String>.from(pickupLocationsListData.cast<String>());
        });
      } else {
        print('Pickup locations document or items field not found.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  TextEditingController title_controller = TextEditingController();
  TextEditingController desc_controller = TextEditingController();
  TextEditingController pickup_instr_controller = TextEditingController();

  List<String> selectedAllergens = [];
  List<String> selectedCategories = [];
  List<String> selectedPickupLocation = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            transitionBetweenRoutes: false,
            backgroundColor: groupedBackgroundColor,
            largeTitle: Text('New Post'),
            leading: GestureDetector(
                child: Icon(
                  FeatherIcons.x,
                  color: CupertinoColors.label.resolveFrom(context),
                  size: 24.0,
                ),
                onTap: () async {
                  // Show a confirmation dialog
                  bool shouldPop = await showConfirmationDialog(context);
                  // Pop the screen only if the user confirms to do so
                  if (shouldPop) {
                    Navigator.of(context).pop();
                  }
                }),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'Save',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                // Check if the fields are empty and if they are display a confirmation dialogue
                if (title_controller.text.isEmpty ||
                    desc_controller.text.isEmpty ||
                    selectedAllergens.isEmpty ||
                    selectedCategories.isEmpty ||
                    selectedPickupLocation.isEmpty ||
                    pickup_instr_controller.text.isEmpty) {
                  // Show an alert or return to prevent saving
                  showEmptyFieldsAlert(context);
                  return;
                }

                // Save the input information to Firestore.
                final user = FirebaseAuth.instance.currentUser;
                String userId = user?.uid ?? 'default uid';

                // Generate a unique document name using uuid
                String documentName = Uuid().v4();

                addDocument(
                  collectionName: 'post_details',
                  filename: documentName,
                  fieldNames: [
                    'title',
                    'description',
                    'allergens',
                    'categories',
                    'expiration_date',
                    'pickup_location',
                    'pickup_instructions',
                    'pickup_time',
                    'user_id',
                    'post_timestamp'
                  ],
                  fieldValues: [
                    title_controller.text,
                    desc_controller.text,
                    selectedAllergens.join(', '),
                    selectedCategories.join(', '),
                    Timestamp.fromDate(selectedDate),
                    selectedPickupLocation.join(', '),
                    pickup_instr_controller.text,
                    Timestamp.fromDate(selectedTime),
                    userId,
                    FieldValue.serverTimestamp(),
                  ],
                );
                // Close the current screen
                Navigator.of(context).pop();
              },
            ),
            border: const Border(bottom: BorderSide.none),
          ),

          // Title text
          buildTextField(text: "Title"),

          // Title input field
          buildTextInputField(
              controller: title_controller,
              placeholder: "",
              padding: EdgeInsets.all(10.0)),

          // Description text
          buildTextField(text: "Description"),

          // Description input field
          buildTextInputField(
              controller: desc_controller,
              placeholder: "",
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0)),

          //Add photo picker and alt text field

          // Allergens text
          buildTextField(text: "Allergens"),

          // Allergens search bar
          SliverToBoxAdapter(
            child: CustomSearchBar.SearchBar(
              itemList: allergensList,
              onItemsSelected: (List<String> items) {
                setState(() {
                  selectedAllergens = items;
                });
              },
            ),
          ),

          // Category text
          buildTextField(text: "Category"),

          // Category search bar
          SliverToBoxAdapter(
            child: CustomSearchBar.SearchBar(
              itemList: categoriesList,
              onItemsSelected: (List<String> items) {
                setState(() {
                  selectedCategories = items;
                });
              },
            ),
          ),

          // Expiration Date Text
          buildTextField(text: "Expiration Date"),

          SliverToBoxAdapter(
            child: CupertinoButton(
              onPressed: () => showDatePickerModal(context),
              child: Text(
                'Expiration Date: ${selectedDate.toLocal()}',
              ),
            ),
          ),
          // Pickup location text
          buildTextField(text: "Pickup Location"),

          // Pickup Location search bar
          SliverToBoxAdapter(
            child: CustomSearchBar.SearchBar(
              itemList: pickupLocationsList,
              onItemsSelected: (List<String> items) {
                setState(() {
                  selectedPickupLocation = items;
                });
              },
            ),
          ),

          // Map displaying location
          SliverToBoxAdapter(
            child: Container(
              height: 200.0, // Set the desired height for the map
              width: double.infinity, // Take the full available width
              margin: EdgeInsets.all(16.0), // Adjust margins as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      37.7749, -122.4194), // Default location (San Francisco)
                  zoom: 12.0,
                ),
                mapType: MapType.normal,
              ),
            ),
          ),

          // Pickup instructions text
          buildTextField(text: "Pickup Instructions"),

          // Pickup instructions text input
          buildTextInputField(
              controller: pickup_instr_controller,
              placeholder: "",
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30.0)),

          // Pickup Time Section
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              padding: EdgeInsets.only(left: 17.0, right: 12.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First widget (Pickup time text)
                  Text(
                    'Pickup Time',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Second widget (Button for time picker)
                  CupertinoButton(
                    onPressed: () => showTimePickerModal(context),
                    child: Text(
                      '${selectedTime.toLocal().hour}:${selectedTime.toLocal().minute}',
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Add space after all widgets
          SliverToBoxAdapter(
            child: SizedBox(height: 40.0),
          ),
        ],
      ),
    );
  }

  // Reusable widget to build the text fields
  Widget buildTextField({
    required String text,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 17.0, top: 10.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Reusable widget to build the input text fields
  Widget buildTextInputField({
    required TextEditingController controller,
    required String placeholder,
    required EdgeInsetsGeometry padding,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
            left: 17.0,
            top: 5.0,
            right: 17.0), // Adjust outer padding as needed
        child: CupertinoTextField(
          controller: controller,
          padding: padding,
          placeholder: placeholder,
          placeholderStyle: TextStyle(
            fontSize: 16.0,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: CupertinoColors.tertiarySystemBackground
                .resolveFrom(context), // Us
          ),
        ),
      ),
    );
  }

  // A function to inform the user cannot save without entering all required information
  void showEmptyFieldsAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content:
              const Text('Please enter all the information before saving.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Function for a pop-up confirmation dialogue after user clicks "x"
Future<bool> showConfirmationDialog(BuildContext context) async {
  bool? result = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context, false); // User doesn't want to exit
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context, true); // User confirms exit
            },
            isDestructiveAction: true,
            child: const Text('Discard'),
          ),
        ],
      );
    },
  );
  return result ?? false; // Use false if result is null
}
