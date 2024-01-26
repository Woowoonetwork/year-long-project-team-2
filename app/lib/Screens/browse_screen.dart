import 'dart:async';

import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:FoodHood/Components/cupertinoSearchNavigationBar.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:FoodHood/firestore_service.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;
  Future<LatLng?>? currentLocationFuture;
  Circle? searchAreaCircle;
  TextEditingController searchController = TextEditingController();

  static const double defaultZoomLevel = 14.0;
  static const LatLng fallbackLocation = LatLng(49.2827, -123.1207);
  static const double baseSearchRadius = 1000;
  double _searchRadius = baseSearchRadius;
  static const Color circleFillColor = Colors.blue;
  static const double circleFillOpacity = 0.1;
  static const Color circleStrokeColor = Colors.blue;
  static const int circleStrokeWidth = 2;
  final GlobalKey navBarKey = GlobalKey();
  bool _isZooming = false;
  double mapBottomPadding = 80; // Default padding

  String? _mapStyle;
  Set<Marker> _markers = {};
  bool _showPostCard = false;
  Map<String, dynamic> _selectedPostData = {};

  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentLocationFuture = _determineCurrentLocation();
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Subscribe
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() => isKeyboardVisible = visible);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _checkAndUpdateMapStyle();
  }

  static const double zoomThreshold = 16.0; // Define a threshold for zoom level
  CameraPosition?
      _lastKnownCameraPosition; // Variable to store last camera position

  void _onCameraMove(CameraPosition position) {
    _lastKnownCameraPosition = position; // Store the last known camera position

    double newZoomLevel = position.zoom;
    setState(() {
      _isZooming = true;
      _searchRadius = _calculateSearchRadius(newZoomLevel);
      if (newZoomLevel > zoomThreshold) {
        // Hide the circle if zoomed in past the threshold
        searchAreaCircle = null;
      } else {
        // Show the circle otherwise
        _updateSearchAreaCircle(position.target);
      }
      _updateMarkersBasedOnCircle();
    });
  }

  void _onCameraIdle() {
    setState(() {
      _isZooming = false;
      if (_lastKnownCameraPosition != null) {
        double currentZoomLevel = _lastKnownCameraPosition!.zoom;
        if (currentZoomLevel <= zoomThreshold && searchAreaCircle == null) {
          // Show the circle again when zooming out past the threshold
          _updateSearchAreaCircle(_lastKnownCameraPosition!.target);
        }
      }
    });
  }

  double _calculateSearchRadius(double newZoomLevel) {
    double scale = math.pow(2, defaultZoomLevel - newZoomLevel).toDouble();
    return baseSearchRadius * scale;
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

  Future<LatLng> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      return currentLatLng;
    } catch (e) {
      // Handle location service errors or user permission issues here
      print("Error fetching location: $e");
      return fallbackLocation; // Return a default location in case of an error
    }
  }

  Future<LatLng?> _determineCurrentLocation() async {
    try {
      LatLng currentLocation = await _fetchCurrentLocation();
      _updateSearchAreaCircle(currentLocation);
      return currentLocation;
    } catch (e) {
      _showErrorDialog(context, 'Location Error',
          'Enable location services in System Settings and try again.');
      return fallbackLocation;
    }
  }

  double getNavBarHeight() {
    final RenderBox? renderBox =
        navBarKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 0;
  }

  void _updateSearchAreaCircle(LatLng location) {
    setState(() {
      searchAreaCircle = Circle(
        circleId: CircleId('searchArea'),
        center: location,
        radius: _searchRadius,
        fillColor: circleFillColor.withOpacity(circleFillOpacity),
        strokeColor: circleStrokeColor,
        strokeWidth: circleStrokeWidth,
      );
    });
  }

  void _onMarkerTapped(String markerId) {
    FirebaseFirestore.instance
        .collection('post_details')
        .doc(markerId)
        .get()
        .then((postDocument) async {
      if (postDocument.exists) {
        Map<String, dynamic> postData =
            postDocument.data() as Map<String, dynamic>;

        String title = postData['title'] ?? 'No Title';

        DateTime createdAt;
        createdAt = (postData['post_timestamp'] as Timestamp).toDate();

        // Fetch user details (assuming 'UserId' is in documentData)
        String userId = postData['user_id'] ?? 'Unknown';
        Map<String, dynamic>? userData = await readDocument(
          collectionName: 'user',
          docName: userId,
        );

        setState(() {
          _showPostCard = true;
          _selectedPostData = {
            'image_url':
                postData['image_url'] ?? 'assets/images/sampleFoodPic.png',
            'title': title,
            'tags': List<String>.from(postData['tags'] ?? []),
            'firstname': userData?['firstName'] ?? 'null',
            'lastname': userData?['lastName'] ?? 'null',
            'timeAgo': timeAgoSinceDate(createdAt),
            'postId': postDocument.id
          };
          _zoomToPostLocation(postData['post_location']);
        });
      }
    }).catchError((error) {
      // Handle error
      print("Error fetching post details: $error");
    });
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);

    if (duration.inDays > 8) {
      return 'on ${DateFormat('MMMM dd, yyyy').format(dateTime)}'; // Format the date
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _zoomToPostLocation(List<dynamic> postLocation) {
    if (postLocation.length != 2) return; // Add this check

    final postLatLng = LatLng(
      double.parse(postLocation[0].toString()),
      double.parse(postLocation[1].toString()),
    );
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: postLatLng, zoom: 18.0)));
  }

  void _resetUIState() {
    setState(() {
      _showPostCard = false;
      _selectedPostData = {};
    });
  }

  void _updateMarkersBasedOnCircle() {
    if (searchAreaCircle == null) return; // Prevents null check exception

    FirebaseFirestore.instance
        .collection('post_details')
        .get()
        .then((querySnapshot) {
      Set<Marker> newMarkers = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<dynamic>? postLocationList = data['post_location'];
        if (postLocationList != null && postLocationList.length == 2) {
          final postLatLng = LatLng(
            double.parse(postLocationList[0].toString()),
            double.parse(postLocationList[1].toString()),
          );

          final double distance = Geolocator.distanceBetween(
            searchAreaCircle!.center.latitude,
            searchAreaCircle!.center.longitude,
            postLatLng.latitude,
            postLatLng.longitude,
          );

          if (distance <= _searchRadius) {
            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: postLatLng,
              onTap: () => _onMarkerTapped(doc.id),
            );
            newMarkers.add(marker);
          }
        }
      }
      setState(() => _markers = newMarkers);
    }).catchError((error) {
      print("Error fetching post details: $error");
    });
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for MediaQuery changes
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    double updatedMapBottomPadding = bottomInset > 0 ? 0 : mapBottomPadding;

    _checkAndUpdateMapStyle();
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildFullScreenMap(updatedMapBottomPadding),
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildFullScreenMap(double bottomPadding) {
    return FutureBuilder<LatLng?>(
      future: currentLocationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error fetching location'));
        }
        if (snapshot.hasData) {
          mapController?.setMapStyle(_mapStyle);
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapBottomPadding = mapBottomPadding;
                mapController = controller;
              },
              onTap: _onMapTapped,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: snapshot.data!,
                zoom: defaultZoomLevel,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              circles: searchAreaCircle != null ? {searchAreaCircle!} : {},
              padding: EdgeInsets.only(
                bottom: mapBottomPadding,
                top: mapBottomPadding,
                right: 0,
                left: 0,
              ),
            ),
            if (_showPostCard) _buildPostCard(),
            if (!_showPostCard) _buildSearchButton(),
          ],
        );
      },
    );
  }

  void _onMapTapped(LatLng tapLocation) {
    if (_lastKnownCameraPosition == null)
      return; // Ensure we have a camera position

    double currentZoomLevel = _lastKnownCameraPosition!.zoom;
    if (currentZoomLevel > zoomThreshold) {
      // Check if tap is outside the search area
      bool isOutside = _isOutsideSearchArea(tapLocation);
      // If zoomed in, zoom out to the default level
      _zoomOutToDefault(isOutside ? tapLocation : null);
      _resetUIState();
    } else {
      // Reset the UI state regardless of where the user taps on the map
      _resetUIState();
    }
  }

  bool _isOutsideSearchArea(LatLng tapLocation) {
    if (searchAreaCircle == null) return true;
    final double distance = Geolocator.distanceBetween(
      searchAreaCircle!.center.latitude,
      searchAreaCircle!.center.longitude,
      tapLocation.latitude,
      tapLocation.longitude,
    );
    return distance > _searchRadius;
  }

  void _zoomOutToDefault([LatLng? customTarget]) {
    LatLng target = customTarget ?? searchAreaCircle!.center;
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: defaultZoomLevel),
      ),
    );
  }

  Widget _buildPostCard() {
    if (_selectedPostData.isEmpty) {
      return SizedBox.shrink();
    }

    // Extract the details from the selected post data
    String imageLocation =
        _selectedPostData['image_url'] ?? 'assets/images/sampleFoodPic.png';
    String title = _selectedPostData['title'] ?? 'Title Not Found';
    List<String> tags = List<String>.from(_selectedPostData['tags'] ?? []);
    String firstname = _selectedPostData['firstname'] ?? 'Unknown';
    String lastname = _selectedPostData['lastname'] ?? 'Unknown';
    String timeAgo = _selectedPostData['timeAgo'] ?? 'Unknown';
    String postId = _selectedPostData['postId'] ?? '0';

    return Positioned(
      bottom: 110,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            // Threshold for swipe down gesture
            _zoomOutToDefault(null);
            _resetUIState();
          }
        },
        onTap: () => _resetUIState(),
        child: PostCard(
          imageLocation: imageLocation,
          title: title,
          tags: tags,
          tagColors: _generateTagColors(tags.length),
          firstname: firstname,
          lastname: lastname,
          timeAgo: timeAgo,
          onTap: (postId) => print('PostCard with ID $postId was tapped'),
          postId: postId,
          showTags: false, // Hide tags
        ),
      ),
    );
  }

  List<Color> _generateTagColors(int numberOfTags) {
    List<Color> tagColors = [];
    List<Color> availableColors = [
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
      Colors.pinkAccent[100]!,
      Colors.yellowAccent[100]!,
    ];
    for (int i = 0; i < numberOfTags; i++) {
      tagColors.add(availableColors[i % availableColors.length]);
    }
    return tagColors;
  }

  Widget _buildSearchButton() {
    return Positioned(
      bottom: 116.0,
      left: 0,
      right: 0,
      child: Center(
        child: CupertinoButton(
          onPressed: _currentLocation,
          color: CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(100.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: _isZooming ? _zoomButtonContent() : _locationButtonContent(),
        ),
      ),
    );
  }

  Row _zoomButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FeatherIcons.maximize2,
            size: 18, color: CupertinoColors.activeOrange),
        SizedBox(width: 8.0),
        Text(
          _formatSearchRadius(_searchRadius * 2),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.8,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        )
      ],
    );
  }

  Row _locationButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.location_fill,
            size: 18, color: CupertinoColors.activeBlue),
        SizedBox(width: 8.0),
        Text(
          'Current Location',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.8,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        CupertinoSearchNavigationBar(
          title: "Browse",
          textController: searchController,
          onSearchTextChanged: (text) {},
          buildFilterButton: () => _buildFilterButton(),
          onSearchBarTapped: _handleSearchBarTapped,
        ),
      ],
    );
  }

  void _handleSearchBarTapped() {
    _resetUIState();
    _updateMapPadding(false); // You need to implement this method
  }

  void _updateMapPadding(bool isKeyboardVisible) {
    setState(() {
      mapBottomPadding = isKeyboardVisible
          ? 0
          : 100; // Update padding based on keyboard visibility
    });
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Container(
        height: 37,
        width: 37,
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(FeatherIcons.filter,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            size: 20),
      ),
    );
  }

  void _currentLocation() async {
    if (mapController == null) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng latLng = LatLng(position.latitude, position.longitude);
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: defaultZoomLevel)));
      _updateSearchAreaCircle(latLng);
    } catch (e) {
      _showErrorDialog(context, 'Location Error',
          'Enable location services in System Settings and try again.');
    }
  }

  void _showFilterSheet() {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor:
          CupertinoDynamicColor.resolve(groupedBackgroundColor, context),
      builder: (context) => SafeArea(
        child: FilterSheet(),
      ),
    );
  }

  String _formatSearchRadius(double radius) {
    if (radius < 1000) {
      return '${radius.toStringAsFixed(0)} m';
    } else {
      return '${(radius / 1000).toStringAsFixed(1)} km';
    }
  }
}

class FilterSheet extends StatefulWidget {
  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String collectionDay = 'Today';
  List<String> selectedFoodTypes = [];
  List<String> selectedDietPreferences = [];
  RangeValues collectionTime = RangeValues(0, 24);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDragHandle(),
        _buildCustomNavigationBar(context),
        _buildFilterOptions(context),
        _buildBottomButtons(context),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavigationBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filter',
              style: TextStyle(
                  fontSize: 28,
                  letterSpacing: -1.3,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.x,
                  size: 24,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context))),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch to full width
          children: [
            _buildTitle('Collection day'),
            _buildSegmentedControl(),
            _buildTitle('Collection time'),
            _buildSlider(context),
            _buildTitle('Food types'),
            _buildCupertinoChoiceButtons(
                ['Meals', 'Bread & pastries', 'Groceries', 'Other'],
                selectedFoodTypes),
            _buildTitle('Diet preferences'),
            _buildCupertinoChoiceButtons(
                ['Vegetarian', 'Vegan'], selectedDietPreferences),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              letterSpacing: -0.5,
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Ensure full width
      child: CupertinoSlidingSegmentedControl<String>(
        children: {
          'Today': Text('Today'),
          'Tomorrow': Text('Tomorrow'),
        },
        onValueChanged: (String? value) {
          if (value != null) {
            setState(() {
              collectionDay = value;
            });
          }
        },
        groupValue: collectionDay,
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: SliderTheme(
          data: SliderThemeData(
            thumbColor: accentColor,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
          ),
          child: RangeSlider(
            values: collectionTime,
            activeColor: accentColor,
            inactiveColor: accentColor.withOpacity(0.3),
            min: 0,
            max: 24,
            divisions: 24,
            onChanged: (RangeValues newRange) {
              setState(() {
                collectionTime = newRange;
              });
            },
            labels: RangeLabels(
              _formatTime(collectionTime.start),
              _formatTime(collectionTime.end),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to format the time
  String _formatTime(double time) {
    final hours = time.toInt();
    final minutes = ((time - hours) * 60).toInt();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Widget _buildCupertinoChoiceButtons(
      List<String> options, List<String> selectedOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: options
            .map((option) => CupertinoButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  borderRadius: BorderRadius.circular(100),
                  color: selectedOptions.contains(option)
                      ? accentColor.resolveFrom(context)
                      : CupertinoColors.tertiarySystemBackground
                          .resolveFrom(context),
                  child: Text(option,
                      style: TextStyle(
                          color: selectedOptions.contains(option)
                              ? CupertinoColors.white
                              : CupertinoColors.label.resolveFrom(context))),
                  onPressed: () {
                    setState(() {
                      if (selectedOptions.contains(option)) {
                        selectedOptions.remove(option);
                      } else {
                        selectedOptions.add(option);
                      }
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: Text('Clear All',
                style: TextStyle(
                    color:
                        CupertinoColors.secondaryLabel.resolveFrom(context))),
            onPressed: () {
              setState(() {
                // Clear filter logic
              });
            },
          ),
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            color: accentColor,
            borderRadius: BorderRadius.circular(100),
            child: Text('Apply',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: CupertinoColors.white)),
            onPressed: () {
              // Apply filter logic
            },
          ),
        ],
      ),
    );
  }
}
