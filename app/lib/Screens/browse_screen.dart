import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:FoodHood/Components/cupertinoSearchNavigationBar.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:FoodHood/Components/post_card.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight, maxHeight;
  final Widget child;

  SliverAppBarDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight ||
      minHeight != oldDelegate.minHeight ||
      child != oldDelegate.child;
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

  String? _mapStyle;
  Set<Marker> _markers = {};
  bool _showPostCard = false;
  Map<String, dynamic> _selectedPostData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentLocationFuture = _determineCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    mapController?.dispose();
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
      _searchRadius = _calculateSearchRadius(newZoomLevel);
      _updateSearchAreaCircle(position.target);
      _updateMarkersBasedOnCircle();
    });
  }

  void _onCameraIdle() => setState(() => _isZooming = false);

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

  // Function to fetch posts from Firestore and display markers within the search area is here
  // Fetch current location function is here
  // Function to determine device's current position is here

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
        .then((document) {
      if (document.exists) {
        setState(() {
          _showPostCard = true;
          _selectedPostData = document.data() as Map<String, dynamic>;
          _zoomToPostLocation(_selectedPostData['post_location']);
          searchAreaCircle = null;
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
        CameraPosition(target: postLatLng, zoom: 18.0)));
  }

  void _resetUIState() {
    setState(() {
      _showPostCard = false;
      _selectedPostData = {};
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
                  left: 0),
            ),
            if (_showPostCard) _buildPostCard(),
            if (!_showPostCard) _buildSearchButton(),
          ],
        );
      },
    );
  }

  void _onMapTapped(LatLng tapLocation) {
    if (_isOutsideSearchArea(tapLocation)) {
      _resetUIState();
      _zoomOutToDefault();
    }
  }

  bool _isOutsideSearchArea(LatLng tapLocation) {
    final double distance = Geolocator.distanceBetween(
      searchAreaCircle!.center.latitude,
      searchAreaCircle!.center.longitude,
      tapLocation.latitude,
      tapLocation.longitude,
    );
    return distance > _searchRadius;
  }

  void _zoomOutToDefault() {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: searchAreaCircle!.center, zoom: defaultZoomLevel),
    ));
  }

  Widget _buildPostCard() {
    if (_selectedPostData.isEmpty) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 110,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _resetUIState(),
        child: PostCard(
          imageLocation: _selectedPostData['imageLocation'] ??
              'assets/images/sampleFoodPic.png',
          title: _selectedPostData['title'] ?? 'Title Not Found',
          tags: List<String>.from(_selectedPostData['tags'] ?? []),
          tagColors: _generateTagColors(_selectedPostData['tags']?.length ?? 0),
          firstname: _selectedPostData['firstname'] ?? 'Null',
          lastname: _selectedPostData['lastname'] ?? 'Null',
          timeAgo: _selectedPostData['timeAgo'] ?? 'Null',
          onTap: (postId) => print('PostCard with ID $postId was tapped'),
          postId: _selectedPostData['postId'] ?? '0',
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
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: 37,
      width: 37,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(FeatherIcons.filter,
          color: CupertinoColors.secondaryLabel.resolveFrom(context), size: 20),
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

  String _formatSearchRadius(double radius) {
    if (radius < 1000) {
      return '${radius.toStringAsFixed(0)} m';
    } else {
      return '${(radius / 1000).toStringAsFixed(1)} km';
    }
  }
}
