import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Needed for ImageFilter
import 'package:FoodHood/Components/cupertinoSearchNavigationBar.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;
  Future<LatLng?>? currentLocationFuture;
  Circle? searchAreaCircle;
  late TextEditingController searchController;

  static const double defaultZoomLevel = 14.0;
  //set fallback location to be the downtown vancouver
  static const LatLng fallbackLocation = LatLng(49.2827, -123.1207);
  static const double baseSearchRadius =
      1000; // Base search radius at default zoom level
  double _searchRadius =
      baseSearchRadius; // Current search radius, starts at base
  static const Color circleFillColor = Colors.blue;
  static const double circleFillOpacity = 0.1;
  static const Color circleStrokeColor = Colors.blue;
  static const int circleStrokeWidth = 2;
  final GlobalKey navBarKey = GlobalKey();
  bool _isZooming = false;

  String? _mapStyle;

  Set<Marker> _markers = {}; // This will hold the map markers
  
  bool _showPostCard = false; // New state to control the visibility of the post card
  Map<String, dynamic> _selectedPostData = {}; // New state to hold the selected post data


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    searchController = TextEditingController();
    currentLocationFuture = _determineCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _checkAndUpdateMapStyle();
  }

  void _onCameraMove(CameraPosition position) {
    double newZoomLevel = position.zoom;
    setState(() {
      _isZooming = true;
      _updateSearchRadius(newZoomLevel, location: position.target);
      _updateSearchAreaCircle(position.target);
    });
  }

  void _onCameraIdle() {
    setState(() {
      _isZooming = false;
      _updateMarkersBasedOnCircle(); // This will update markers based on the new circle position
    });
  }

  void _updateSearchRadius(double newZoomLevel, {LatLng? location}) {
    // Define a scaling factor based on zoom level. You might need to adjust the formula.
    double scale = math.pow(2, defaultZoomLevel - newZoomLevel).toDouble();
    setState(() {
      _searchRadius = baseSearchRadius * scale;
      _updateSearchAreaCircle(location ?? searchAreaCircle!.center);
      _updateMarkersBasedOnCircle(); // This will update markers based on the new circle position
    });
  }

  void _checkAndUpdateMapStyle() async {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String stylePath = isDarkMode
        ? 'assets/map_style_dark.json'
        : 'assets/map_style_light.json';

    String style = await rootBundle.loadString(stylePath);
    if (_mapStyle != style) {
      setState(() {
        _mapStyle = style;
      });
      mapController?.setMapStyle(_mapStyle);
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
      return fallbackLocation; // Default fallback location
    }
  }

  // Fetch posts from Firestore and display markers within the search area
  void _fetchPostsAndDisplayMarkers() async {
    LatLng? currentLocation = await currentLocationFuture;
    if (currentLocation != null) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('post_details').get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<dynamic>? postLocationList = data['post_location'];
        if (postLocationList != null && postLocationList.length == 2) {
          final postLatLng = LatLng(
            double.parse(postLocationList[0].toString()),
            double.parse(postLocationList[1].toString()),
          );

          // Check if the post's location is within the search area circle
          final double distance = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            postLatLng.latitude,
            postLatLng.longitude,
          );

          if (distance <= _searchRadius) {
            // If within the circle, add a marker to the map
            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: postLatLng,
              infoWindow: InfoWindow(
                title: data[
                    'title'], // Assuming 'title' is a field in your document
                snippet: data[
                    'description'], // Assuming 'description' is a field in your document
              ),
            );

            setState(() {
              _markers.add(marker); // Add the marker to the set
            });
          }
        }
      }
    }
  }

  Future<LatLng> _fetchCurrentLocation() async {
    Position position = await _determinePosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition();
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
    // Fetch post data from Firestore using the markerId
    FirebaseFirestore.instance
        .collection('post_details')
        .doc(markerId)
        .get()
        .then((document) {
      if (document.exists) {
        setState(() {
          _showPostCard = true;
          _selectedPostData = document.data() as Map<String, dynamic>;
          _zoomToPostLocation(_selectedPostData['post_location']);
        });
      }
    });
  }

  void _zoomToPostLocation(List<dynamic> postLocation) {
    final postLatLng = LatLng(
      double.parse(postLocation[0].toString()),
      double.parse(postLocation[1].toString()),
    );
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: postLatLng, zoom: 18.0), // A closer zoom level
    ));
  }

  void _resetUIState() {
    setState(() {
      _showPostCard = false;
      _selectedPostData = {};
      // Optionally, animate back to the user's location or previous zoom level
    });
  }


  void _updateMarkersBasedOnCircle() {
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

          // Check if the post's location is within the search area circle
          final double distance = Geolocator.distanceBetween(
            searchAreaCircle!.center.latitude,
            searchAreaCircle!.center.longitude,
            postLatLng.latitude,
            postLatLng.longitude,
          );

          if (distance <= _searchRadius) {
            // If within the circle, add a marker to the map
            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: postLatLng,
              infoWindow: InfoWindow(
                title: data['title'],
                snippet: data['description'],
              ),
            );
            newMarkers.add(marker);
          }
        }
      }

      setState(() {
        _markers = newMarkers;
      });
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check and load the map style based on the theme
    _checkAndUpdateMapStyle();

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildFullScreenMap(),
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildFullScreenMap() {
    double mapBottomPadding = 100;
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
                mapBottomPadding = 100;
                mapController = controller;
              },
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
                  left: 0),
            ),
            if (_showPostCard) _buildPostCard(), // Conditionally render the post card
          if (!_showPostCard) _buildSearchButton(), // Hide the search button when post card is shown
          ],
        );
      },
    );
  }

  String _formatSearchRadius(double radius) {
    if (radius < 1) {
      return '<1 m';
    } else if (radius < 1000) {
      return '${radius.toStringAsFixed(0)} m';
    } else {
      return '${(radius / 1000).toStringAsFixed(0)} km';
    }
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
          child: _isZooming
              ? Row(
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
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.location_fill,
                        size: 18, color: CupertinoColors.activeBlue),
                    SizedBox(width: 8.0),
                    Text(
                      'Search Here',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.8,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(children: [
      CupertinoSearchNavigationBar(
        title: "Browse",
        textController: searchController,
        focusNode: FocusNode(),
        onSearchTextChanged: (text) {},
        buildFilterButton: () {
          return _buildFilterButton();
        },
      ),
    ]);
  }

  Widget _buildFilterButton() {
    return Container(
      height: 37,
      width: 37,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(FeatherIcons.filter,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            size: 20),
        onPressed: () {},
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
}
