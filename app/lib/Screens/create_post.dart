// create_post.dart
// a page that allows users to create a new post
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:FoodHood/Screens/home_screen.dart';
// import 'package:FoodHood/Screens/navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
} 

class _CreatePostPageState extends State<CreatePostScreen> {

  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  TextEditingController title_controller = TextEditingController();
  TextEditingController desc_controller = TextEditingController();
  TextEditingController pickup_instr_controller = TextEditingController();
  TextEditingController allergen_controller = TextEditingController();
  String allergen_search_value = '';
  TextEditingController category_controller = TextEditingController();
  String category_search_value = '';
  TextEditingController pickup_loc_controller = TextEditingController();
  String pickup_loc_search_value = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1.0),
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.extraLightBackgroundGray,
            largeTitle: const Text(
              'New Post',
              style: TextStyle(
                letterSpacing: -1.36,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.clear, color: CupertinoColors.black),
              onPressed: () async{
                // add onPressed functionality
                //Navigator.pop(context);
                //Navigator.of(context).pop();
                // Show a confirmation dialog
                bool shouldPop = await showConfirmationDialog(context);

                // Pop the screen only if the user confirms
                if (shouldPop) {
                  Navigator.of(context).pop();
                }
              }      
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF337586), // Your custom color
                ),
              ),
              onPressed: () async{
                // Save the input information to Firestore.
                final user = FirebaseAuth.instance.currentUser;
                //Access the user's email id and replace special characters in it to adhere to Firestore's document name rules
                String userEmail = user?.email?.replaceAll('.', '_').replaceAll('@', '_') ?? 'default email'; 
                addDocument(
                  collectionName: 'post_details',
                  filename: userEmail,
                  fieldNames: ['title', 'description', 'allergens', 'expiration_date','category', 'pickup_location', 'pickup_instructions', 'pickup_time'],
                  fieldValues: [title_controller.text, desc_controller.text, allergen_controller.text, Timestamp.fromDate(selectedDate), category_controller.text, pickup_loc_controller.text,pickup_instr_controller.text, Timestamp.fromDate(selectedTime)],
                );
                // Close the current screen
                //Navigator.of(context).pop();
              },
            ),
            border: const Border(bottom: BorderSide.none),
          ),
          
          //Title text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Title",
              ),
            ),
          ),

          //Title input field
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0), // Adjust padding as needed
              child: CupertinoTextField(
                controller: title_controller,
                padding: EdgeInsets.all(10.0),
                placeholder: 'Enter a title', // Placeholder text
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.white,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),

          //Description text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Description",
              ),
            ),
          ),

          //Description input field
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0), // Adjust padding as needed
              child: CupertinoTextField(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
                controller: desc_controller,
                placeholder: 'No Description Entered', // Placeholder text
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.white,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),

          //Add photo picker and alt text field
          

          //Allergens text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Allergens",
              ),
            ),
          ),

          //Allergens search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0, right: 17.0, bottom: 60.0),
              child: CupertinoSearchTextField(
                controller: allergen_controller,
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                  setState(() {
                    allergen_search_value = value;
                  });
                },
                backgroundColor: CupertinoColors.white,
                onChanged: (value){
                  setState(() {
                    allergen_search_value = value;
                  });
                },
              ),
            ),
          ),

          //Expiration Date
          SliverToBoxAdapter(
            child: Container( 
              height: 80,
              child: Padding(
                padding: EdgeInsets.only(left: 17.0, right: 12.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    // First widget (Expiration date text)
                    const Text(
                      'Expiration Date',
                    ),
                    
                    SizedBox(width: 5.0), // Adjust spacing between the widgets

                    // Second widget (Date picker for expiration date)
                    Container(
                      width: 268,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() {
                            selectedDate = newDate;
                          });
                        },
                      ),     
                    )  
                  ],
                ),
              ),
            )
          ),

          //Category text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Category",
              ),
            ),
          ),

          //Category search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0, right: 17.0, bottom: 60.0),
              child: CupertinoSearchTextField(
                controller: category_controller,
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                  setState(() {
                    category_search_value = value;
                  });
                },
                backgroundColor: CupertinoColors.white,
                onChanged: (value){
                  setState(() {
                    category_search_value = value;
                  });
                },
              ),
            ),
          ),

          //Pickup location text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Pickup Location",
              ),
            ),
          ),

          //Pickup Location search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0, right: 17.0, bottom: 60.0),
              child: CupertinoSearchTextField(
                controller: pickup_loc_controller,
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                  setState(() {
                    pickup_loc_search_value = value;
                  });
                },
                backgroundColor: CupertinoColors.white,
                onChanged: (value){
                  setState(() {
                    pickup_loc_search_value = value;
                  });
                },
              ),
            ),
          ),

          //Map displaying location 
          SliverToBoxAdapter(
            child: Container(
              height: 200.0, // Set the desired height for the map
              width: double.infinity, // Take the full available width
              margin: EdgeInsets.all(16.0), // Adjust margins as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
                    zoom: 12.0,
                ),
                
                mapType: MapType.normal,  
              ),
            ),
          ),

          //Pickup instructions text
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 10.0),
              child: Text(
                "Pickup Instructions",
              ),
            ),
          ),

          //Pickup instructions text input
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0), // Adjust padding as needed
              child: CupertinoTextField(
                controller: pickup_instr_controller,
                padding: EdgeInsets.all(10.0),
                placeholder: 'No pickup instructions entered', // Placeholder text
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.white,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),

          //Pickup Time
          SliverToBoxAdapter(
            child: Container( 
              height: 80,
              child: Padding(
                padding: EdgeInsets.only(left: 17.0, right: 12.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    // First widget (Pickup time text)
                    const Text(
                      'Pickup Time',
                    ),
                    
                    SizedBox(width: 5.0), // Adjust spacing between the widgets

                    // Second widget (Time picker for pickup time)
                    Container(
                      width: 268,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: selectedTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() {
                            selectedTime = newTime;
                          });
                        },
                      ),     
                    )  
                  ],
                ),
              ),
            )
          ),

          //Add space after all widgets
          const SliverToBoxAdapter(
            child: SizedBox(height: 50.0),
          )

        ],
      ),
    );
  }
}

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
              //Navigator.of(context, rootNavigator: true).pop(context);
              //Navigator.popUntil(context, 'ModalRoute.withName('/')');
              //  Navigator.pushReplacement(
              //   context,
              //   CupertinoPageRoute(builder: (context) => HomeScreen()),
              // );
              //Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => NavigationScreen(selectedIndex: 0, onItemTapped: (int index) {})));
              
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
