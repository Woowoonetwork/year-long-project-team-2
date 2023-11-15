// create_post.dart
// a page that allows users to create a new post
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
} 

class _CreatePostPageState extends State<CreatePostScreen> {

  DateTime selectedDateandTime = DateTime.now();

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
              onPressed: () {
                // add onPressed functionality
                Navigator.of(context).pop();
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
              onPressed: () {
                //Add your onPressed functionality here
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
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                },
                backgroundColor: CupertinoColors.white,
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
                        initialDateTime: selectedDateandTime,
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() {
                            selectedDateandTime = newDate;
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
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                },
                backgroundColor: CupertinoColors.white,
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
                padding: EdgeInsets.all(10.0),
                placeholder: 'Search',
                onSubmitted: (String value) {
                  // Handle search submission
                },
                backgroundColor: CupertinoColors.white,
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
                        initialDateTime: selectedDateandTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() {
                            selectedDateandTime = newTime;
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
