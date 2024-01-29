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
            buildTextField('Title'),
            buildTextInputField(titleController, '', EdgeInsets.all(10.0)),
            buildTextField('Description'),
            buildTextInputField(descController, '',
                EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0)),
            buildTextField('Allergens'),
            buildSearchBar(allergensList, selectedAllergens),
            buildExpireDateSection(),
            buildTextField('Category'),
            buildSearchBar(categoriesList, selectedCategories),
            buildTextField('Pickup Location'),
            buildSearchBar(pickupLocationsList, selectedPickupLocation),
            buildMapSection(),
            buildTextField('Pickup Instructions'),
            buildTextInputField(pickupInstrController, '',
                EdgeInsets.symmetric(horizontal: 8, vertical: 30.0)),
            buildTimeSection(),
            SliverToBoxAdapter(child: SizedBox(height: 40.0)),
          ],
        ),
      ),
    );
  }

  CupertinoSliverNavigationBar buildSliverNavigationBar(BuildContext context) {
    return CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor: groupedBackgroundColor,
      largeTitle: Text('New Post'),
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
    if ([titleController, descController, pickupInstrController]
            .any((c) => c.text.isEmpty) ||
        [selectedAllergens, selectedCategories, selectedPickupLocation]
            .any((l) => l.isEmpty)) {
      showEmptyFieldsAlert(context);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'default uid';
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
        'post_location',
        'post_timestamp'
      ],
      fieldValues: [
        titleController.text,
        descController.text,
        selectedAllergens.join(', '),
        selectedCategories.join(', '),
        Timestamp.fromDate(selectedDate),
        selectedPickupLocation.join(', '),
        pickupInstrController.text,
        Timestamp.fromDate(selectedTime),
        userId,
        [selectedLocation!.latitude, selectedLocation!.longitude],
        FieldValue.serverTimestamp()
      ],
    );
    Navigator.of(context).pop();
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

  SliverToBoxAdapter buildTextInputField(TextEditingController controller,
      String placeholder, EdgeInsetsGeometry padding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 17.0, top: 5.0, right: 17.0),
        child: CupertinoTextField(
            controller: controller,
            padding: padding,
            placeholder: placeholder,
            placeholderStyle: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: CupertinoColors.tertiarySystemBackground
                    .resolveFrom(context))),
      ),
    );
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
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
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
        height: 200.0, // Adjust the height as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0), // Set corner radius
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
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
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 12));
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
