import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BrowseScreenViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Circle? searchAreaCircle;
  Set<Marker> markers = {};
  bool isZooming = false;
  double searchRadius = 1000;
  Map<String, dynamic> selectedPostData = {};
  bool showPostCard = false;

  static const double defaultZoomLevel = 14.0;
  static const LatLng fallbackLocation = LatLng(49.2827, -123.1207);
  static const double baseSearchRadius = 1000;
  static const Color circleFillColor = Colors.blue;
  static const double circleFillOpacity = 0.1;
  static const Color circleStrokeColor = Colors.blue;
  static const int circleStrokeWidth = 2;

  Future<void> determineCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation = LatLng(position.latitude, position.longitude);
      updateSearchAreaCircle(currentLocation!);
      notifyListeners();
    } catch (e) {
      // Handle location errors or user permission issues
      currentLocation = fallbackLocation;
    }
  }

  void onCameraMove(CameraPosition position) {
    double newZoomLevel = position.zoom;
    isZooming = true;
    searchRadius = _calculateSearchRadius(newZoomLevel);
    updateSearchAreaCircle(position.target);
    updateMarkersBasedOnCircle();
    notifyListeners();
  }

  void onCameraIdle() {
    isZooming = false;
    notifyListeners();
  }

  double _calculateSearchRadius(double newZoomLevel) {
    double scale = math.pow(2, defaultZoomLevel - newZoomLevel).toDouble();
    return baseSearchRadius * scale;
  }

  void updateSearchAreaCircle(LatLng location) {
    searchAreaCircle = Circle(
      circleId: CircleId('searchArea'),
      center: location,
      radius: searchRadius,
      fillColor: circleFillColor.withOpacity(circleFillOpacity),
      strokeColor: circleStrokeColor,
      strokeWidth: circleStrokeWidth,
    );
    notifyListeners();
  }

  void onMarkerTapped(String markerId) {
    FirebaseFirestore.instance.collection('post_details').doc(markerId).get().then((document) {
      if (document.exists) {
        showPostCard = true;
        selectedPostData = document.data() as Map<String, dynamic>;
        zoomToPostLocation(selectedPostData['post_location']);
        searchAreaCircle = null;
        notifyListeners();
      }
    });
  }

  void zoomToPostLocation(List<dynamic> postLocation) {
    final postLatLng = LatLng(
      double.parse(postLocation[0].toString()),
      double.parse(postLocation[1].toString()),
    );
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: postLatLng, zoom: 17.0)));
  }

  void resetUIState() {
    showPostCard = false;
    selectedPostData = {};
    notifyListeners();
  }

  void updateMarkersBasedOnCircle() {
    FirebaseFirestore.instance.collection('post_details').get().then((querySnapshot) {
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

          if (distance <= searchRadius) {
            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: postLatLng,
              onTap: () => onMarkerTapped(doc.id),
            );
            newMarkers.add(marker);
          }
        }
      }
      markers = newMarkers;
      notifyListeners();
    });
  }

  String formatSearchRadius(double radius) {
    if (radius < 1000) {
      return '${radius.toStringAsFixed(0)} m';
    } else {
      return '${(radius / 1000).toStringAsFixed(1)} km';
    }
  }
}
