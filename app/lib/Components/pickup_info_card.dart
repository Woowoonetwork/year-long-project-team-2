import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:FoodHood/Screens/message_screen.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'dart:io' show Platform;
import 'package:FoodHood/Screens/posting_detail.dart'; // Update this import

class PickupInformation extends StatefulWidget {
  final String pickupTime;
  final String pickupLocation;
  final String meetingPoint;
  final String additionalInfo;
  final LatLng? locationCoordinates;
  final PostDetailViewModel viewModel;

  const PickupInformation({
    Key? key,
    required this.pickupTime,
    required this.pickupLocation,
    required this.meetingPoint,
    required this.additionalInfo,
    this.locationCoordinates,
    required this.viewModel,
  }) : super(key: key);

  @override
  _PickupInformationState createState() => _PickupInformationState();
}

class _PickupInformationState extends State<PickupInformation>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late Future<void> _delayFuture;
  String? _mapStyle;
  GoogleMapController? mapController;
  @override
  void initState() {
    super.initState();
    _delayFuture = Future.delayed(Duration(milliseconds: 300));
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _checkAndUpdateMapStyle();
  }

  @override
  void dispose() {
    super.dispose();
    mapController?.dispose();
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
  Widget build(BuildContext context) {
    _checkAndUpdateMapStyle();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeader(context),
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(
        'Pickup Information',
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.70,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          _buildMap(context),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildDetails(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: const Color(0x19000000),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return FutureBuilder(
      future: _delayFuture, // Use the initialized future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              color: CupertinoColors.systemGrey6,
            ),
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(),
          );
        } else {
          if (widget.locationCoordinates != null) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                width: double.infinity,
                height: 140.0,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.viewModel.pickupLatLng,
                    zoom: 16.0,
                  ),
                  markers: Set.from([
                    Marker(
                      markerId: MarkerId('pickupLocation'),
                      position: widget.viewModel.pickupLatLng,
                    ),
                  ]),
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  myLocationEnabled: false,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                ),
              ),
            );
          } else {
            return Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: CupertinoColors.systemGrey4,
              ),
              alignment: Alignment.center,
              child: Text('Map Placeholder'),
            );
          }
        }
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(_mapStyle);
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInfoTile(title: 'Pickup Time', subtitle: widget.pickupTime),
        CustomInfoTile(
            title: 'Pickup Location', subtitle: widget.pickupLocation),
        const SizedBox(height: 12),
        _buildAdditionalInfo(context),
        const SizedBox(height: 12),
        _buildButtonBar(context),
      ],
    );
  }

  Future<void> _launchMapUrl(LatLng locationCoordinates) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${locationCoordinates.latitude},${locationCoordinates.longitude}';
    final String appleMapsUrl =
        'http://maps.apple.com/?q=${locationCoordinates.latitude},${locationCoordinates.longitude}';

    HapticFeedback.selectionClick();
    // Check if the device is running on iOS
    if (Platform.isIOS) {
      // Attempt to open Apple Maps
      if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl);
      } else {
        throw 'Could not launch $appleMapsUrl';
      }
    } else {
      // Attempt to open Google Maps or the default map application on other devices
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    }
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Container(
              width: 30.0,
              height: 30.0,
              child: //clipoval
                  IconPlaceholder(imageUrl: widget.viewModel.profileURL)),
        ),
        Expanded(
          child: MessageBox(context: context, text: widget.additionalInfo),
        ),
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: InfoButton(
              context: context,
              text: 'Message ${widget.viewModel.firstName}',
              icon: FeatherIcons.messageCircle,
              iconColor: CupertinoColors.label.resolveFrom(context),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => MessageScreenPage()),
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: InfoButton(
              context: context,
              text: 'Navigate Here',
              icon: FeatherIcons.arrowUpRight,
              iconColor: CupertinoColors.label.resolveFrom(context),
              onPressed: () => _launchMapUrl(widget.viewModel.pickupLatLng),
            ),
          ),
        ],
      ),
    );
  }
}
