import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class GoogleMapWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;

  GoogleMapWidget({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? mapController;
  String? _mapStyle;
  LatLng? currentCenter;
  Brightness? currentBrightness;
  bool _isLoading = true; // Add this line
  LatLng? _lastMapPosition;

  @override
  void initState() {
    super.initState();

    _determinePosition().then((position) {
      LatLng initialPosition =
          widget.initialLocation ?? LatLng(37.7749, -122.4194);
      if (position != null) {
        initialPosition = LatLng(position.latitude, position.longitude);
      }
      setState(() {
        currentCenter = initialPosition;
        _isLoading = false; // Update loading state
      });
    }).catchError((e) {
      print('Location permission error: $e');
      setState(() {
        currentCenter = widget.initialLocation ?? LatLng(37.7749, -122.4194);
        _isLoading = false; // Update loading state
      });
    });
    currentCenter = widget.initialLocation ?? LatLng(37.7749, -122.4194);
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
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
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _goToMyLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng myLocation = LatLng(position.latitude, position.longitude);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(myLocation, 14));
    setState(() => currentCenter = myLocation);
    widget.onLocationSelected
        .call(myLocation); // Call the callback with the new center
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentCenter!, zoom: 16.0),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    currentCenter = position.target;
  }

  void _onCameraIdle() {
    if (_lastMapPosition != null) {
      setState(() {
        // When the camera stops moving, update the marker position.
        currentCenter = _lastMapPosition;
      });
      widget.onLocationSelected(_lastMapPosition!);
    }
  }

  Future<void> _setMapStyle() async {
    String style = await rootBundle.loadString(
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? 'assets/map_style_dark.json'
            : 'assets/map_style_light.json');
    if (_mapStyle != style) {
      setState(() {
        _mapStyle = style;
      });
      mapController?.setMapStyle(_mapStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: currentCenter ?? LatLng(37.7749, -122.4194),
            zoom: 12.0,
          ),
          onCameraMove: (CameraPosition position) {
            _onCameraMove(position);
            widget.onLocationSelected(position
                .target); // This will send the new position back to the parent widget
          },
          onCameraIdle:
              _onCameraIdle, // Update the marker position when the camera is idle.

          markers: {
            Marker(
              markerId: MarkerId("centerMarker"),
              position:
                  currentCenter!, // Marker is now always at the current center
              infoWindow: InfoWindow(title: "Center Location"),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          gestureRecognizers: Set()
            ..add(Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer())),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: CupertinoButton(
            onPressed: _goToMyLocation,
            color: CupertinoColors.tertiarySystemBackground,
            borderRadius: BorderRadius.circular(100.0),
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Icon(CupertinoIcons.location_fill,
                size: 18, color: CupertinoColors.activeBlue),
          ),
        ),
      ],
    );
  }

  void _checkAndUpdateMapStyle() async {
    String style = await rootBundle.loadString(
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? 'assets/map_style_dark.json'
            : 'assets/map_style_light.json');
    if (_mapStyle != style) {
      setState(() => _mapStyle = style);
      mapController?.setMapStyle(_mapStyle);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to access MediaQuery and other inherited widgets
    currentBrightness = MediaQuery.of(context).platformBrightness;
    _checkAndUpdateMapStyle(); // Now you can call this method
  }
}
