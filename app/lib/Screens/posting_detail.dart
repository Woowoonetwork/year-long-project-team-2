import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/foodAppBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:FoodHood/Components/cupertinosnackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Screens/donee_pathway_uno.dart';

class PostDetailView extends StatefulWidget {
  final String postId;
  const PostDetailView({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailViewState createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  late PostDetailViewModel viewModel;
  AnimationController? _animationController;
  bool isLoading = true; // Added to track loading status

  @override
  void initState() {
    super.initState();

    viewModel = PostDetailViewModel(widget.postId);

    viewModel.fetchData(widget.postId).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

// Define your colors here
  final List<Color> colors = [
    Colors.lightGreenAccent, // Light Green
    Colors.lightBlueAccent, // Light Blue
    Colors.pinkAccent[100]!, // Light Pink
    Colors.yellowAccent[100]! // Light Yellow
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(detailsBackgroundColor, context),
      body: isLoading ? _buildLoadingScreen() : _buildContent(context),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CupertinoActivityIndicator(
        radius: 16,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      FoodAppBar(
                        postId: widget.postId, // Pass postId to the FoodAppBar
                        isFavorite: viewModel.isFavorite,
                        onFavoritePressed:
                            _handleFavoritePressed, // Pass the callback function
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPostTitleSection(),
                                const SizedBox(height: 16),
                                _buildDescription(),
                                const SizedBox(height: 16),
                                _buildInfoCards(),
                                _buildPickupInformation(),
                                const SizedBox(height: 16),
                                _buildAllergensSection(),
                                const SizedBox(height: 16),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onRefresh: () => Future.value(true)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: ReserveButton(isReserved: false),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleFavoritePressed() async {
    setState(() {
      viewModel.isFavorite = !viewModel.isFavorite;
    });

    if (viewModel.isFavorite) {
      await viewModel.savePost(widget.postId);
      showCupertinoSnackbar(
        context,
        'Saved "${viewModel.title}" to the list',
        accentColor,
        Icon(FeatherIcons.check, color: Colors.white),
        _reverseAnimation, // Pass _reverseAnimation as the callback
      );
    } else {
      await viewModel.unsavePost(widget.postId);
      showCupertinoSnackbar(
        context,
        'Removed "${viewModel.title}" from the list',
        yellow,
        Icon(FeatherIcons.x, color: Colors.white),
        _reverseAnimation, // Pass _reverseAnimation as the callback
      );
    }
  }

  void _reverseAnimation() {
    // Reverse your animation here
    _animationController?.reverse();
  }

  void showCupertinoSnackbar(BuildContext context, String message,
      Color backgroundColor, Icon trailingIcon, VoidCallback onSnackbarClosed) {
    var overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: CupertinoSnackbar(
          message: message,
          backgroundColor: backgroundColor,
          trailingIcon: trailingIcon,
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    // Use Future.delayed to wait for the duration of the snackbar display
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
      onSnackbarClosed(); // Call the provided callback function
    });
  }

  Widget _buildPostTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              viewModel.title, // Updated to use viewModel
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
                letterSpacing: -1.45,
                fontSize: 28,
              ),
            ),
          ),
          AvailabilityIndicator(
              isReserved: false), // Placeholder, update as needed
        ],
      ),
    );
  }

  Color _generateTagColor(int index) {
    List<Color> availableColors = [yellow, orange, blue, babyPink, Cyan];
    return availableColors[index % availableColors.length];
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.description, // Updated to use viewModel
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withOpacity(0.6), // Corrected opacity usage
                  letterSpacing: -0.62,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: 12),
          _buildTagSection(context), // Updated to use viewModel
          const SizedBox(height: 12),
          InfoRow(
            firstName: viewModel.firstName,
            lastName: viewModel.lastName,
            postTimestamp: viewModel.postTimestamp,
            viewModel: viewModel, // Pass the viewModel to InfoRow
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(BuildContext context) {
    const double horizontalSpacing = 7.0;
    return Row(
      children: List.generate(viewModel.tags.length, (index) {
        return Row(
          children: [
            _buildTag(viewModel.tags[index], _generateTagColor(index), context),
            SizedBox(width: horizontalSpacing),
          ],
        );
      }),
    );
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: CupertinoDynamicColor.resolve(CupertinoColors.black, context),
          fontSize: 10,
          letterSpacing: -0.40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return InfoCardsRow(
      expirationDate: viewModel.expirationDate, // Updated to use viewModel
      pickupTime: viewModel.pickupTime, // Updated to use viewModel
      allergens: viewModel.allergens, // Updated to use viewModel
    );
  }

  Widget _buildPickupInformation() {
    LatLng? pickupCoordinates =
        viewModel.pickupLatLng; // Updated to use viewModel
    return PickupInformation(
      pickupTime:
          DateFormat('EEE, MMM d, ' 'h:mm a').format(viewModel.pickupTime),
      pickupLocation: viewModel.pickupLocation,
      meetingPoint: '330, 1130 Trello Way\nKelowna, BC\nV1V 5E0',
      additionalInfo: 'Please reach out for any additional details!',
      locationCoordinates: pickupCoordinates,
      viewModel: viewModel, // Pass viewModel here
    );
  }

  Widget _buildAllergensSection() {
    List<String> allergenList =
        viewModel.allergens.split(', '); // Updated to use viewModel
    return AllergensSection(allergens: allergenList);
  }

  // Widget _buildReserveButton() {
  //   return ReserveButton(isReserved: false); // Placeholder, update as needed
  // }
}

// The remaining widget classes like `AvailabilityIndicator`, `InfoRow`, etc., would follow.
// AvailabilityIndicator, InfoRow, and other supporting widgets

class AvailabilityIndicator extends StatelessWidget {
  final bool isReserved;

  const AvailabilityIndicator({Key? key, required this.isReserved})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = isReserved
        ? CupertinoColors.systemRed.withOpacity(0.15)
        : CupertinoColors.activeGreen.withOpacity(0.15);

    Color circleColor =
        isReserved ? CupertinoColors.systemRed : CupertinoColors.activeGreen;
    String statusText = isReserved ? 'Reserved' : 'Available';

    return Container(
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime postTimestamp;
  final PostDetailViewModel viewModel;

  const InfoRow({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.postTimestamp,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconPlaceholder(imageUrl: 'assets/images/sampleProfile.png'),
          const SizedBox(width: 8),
          Expanded(
            // Wrap with Expanded to prevent overflow
            child: CombinedTexts(
              firstName: firstName,
              lastName: lastName,
              postTimestamp: postTimestamp,
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    );
  }
}

class IconPlaceholder extends StatelessWidget {
  final String imageUrl; // Add a parameter for the image URL

  IconPlaceholder({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(imageUrl), // Replace with your image provider
        ),
      ),
    );
  }
}

class CombinedTexts extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime postTimestamp;
  final PostDetailViewModel viewModel; // Add the viewModel here

  const CombinedTexts({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.postTimestamp,
    required this.viewModel, // Include viewModel in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Made by $firstName $lastName  Posted ${viewModel.timeAgoSinceDate(postTimestamp)}',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.48,
          ),
        ),
        Text("  "),
        RatingText(), // Placeholder widget for rating, update as needed
      ],
    );
  }
}

class InfoText extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime postTimestamp;
  final PostDetailViewModel viewModel; // Add viewModel here

  const InfoText({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.postTimestamp,
    required this.viewModel, // Include viewModel in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.fade,
      text: TextSpan(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.48,
        ),
        children: <TextSpan>[
          TextSpan(text: 'Prepared by $firstName $lastName'),
          TextSpan(text: '   '),
          TextSpan(
            text:
                'Posted ${viewModel.timeAgoSinceDate(postTimestamp)}', // Use viewModel here
            style: TextStyle(letterSpacing: -0.48),
          ),
        ],
      ),
    );
  }
}

class RatingText extends StatelessWidget {
  // Placeholder widget for rating, update as needed
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: secondaryColor,
          size: 14,
        ),
        const SizedBox(width: 3),
        Text(
          '5.0 Rating', // Placeholder rating
          style: TextStyle(
            overflow: TextOverflow.fade,
            color: CupertinoColors.label.resolveFrom(context).withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.48,
          ),
        ),
      ],
    );
  }
}

class InfoCardsRow extends StatelessWidget {
  final DateTime expirationDate;
  final DateTime pickupTime;
  final String allergens;

  const InfoCardsRow(
      {Key? key,
      required this.expirationDate,
      required this.pickupTime,
      required this.allergens})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedExp = DateFormat('d MMM yyyy').format(expirationDate);
    String formattedPick = DateFormat('h:mm a').format(pickupTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildInfoCard(
            icon: FeatherIcons.meh,
            title: 'Expiration Date',
            subtitle: formattedExp,
            context: context,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 16),
          buildInfoCard(
            icon: FeatherIcons.shoppingBag,
            title: 'Pickup Time',
            subtitle: formattedPick,
            context: context,
            color: blue, // Placeholder color, update as needed
          ),
          const SizedBox(width: 16),
          buildInfoCard(
            icon: FeatherIcons.alertCircle,
            title: 'Allergens',
            subtitle: allergens.isEmpty ? 'None' : allergens,
            context: context,
            color: yellow, // Placeholder color, update as needed
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
    required Color color,
  }) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.label.resolveFrom(context),
                letterSpacing: -0.84,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey.resolveFrom(context),
                letterSpacing: -0.84,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Continue with the remaining widget classes like PickupInformation, CustomInfoTile, etc.
class PickupInformation extends StatelessWidget {
  final String pickupTime;
  final String pickupLocation;
  final String meetingPoint;
  final String additionalInfo;
  final LatLng? locationCoordinates; // Make nullable
  final PostDetailViewModel viewModel;

  const PickupInformation({
    Key? key,
    required this.pickupTime,
    required this.pickupLocation,
    required this.meetingPoint,
    required this.additionalInfo,
    this.locationCoordinates, // Nullable
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          blurRadius: 20,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    // Check if locationCoordinates are available from the viewModel
    final LatLng? locationCoordinates = viewModel.pickupLatLng;

    // If coordinates are available, display GoogleMap
    if (locationCoordinates != null) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: 188.0, // Assign a finite height to the map container
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationCoordinates,
              zoom: 16.0,
            ),
            markers: Set.from([
              Marker(
                markerId: MarkerId('pickupLocation'),
                position: locationCoordinates,
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
        child: Text('Map Placeholder'), // Placeholder text
      );
    }
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInfoTile(title: 'Pickup Time', subtitle: pickupTime),
        CustomInfoTile(
            title: 'Pickup Location',
            subtitle: viewModel
                .pickupLocation), // Use viewModel for dynamic meeting point
        const SizedBox(height: 12),
        _buildAdditionalInfo(context),
        const SizedBox(height: 12),
        _buildButtonBar(context),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Row(
      children: [
        // Leading Circular Cropped Image
        Padding(
          padding: EdgeInsets.only(right: 8.0), // Adjust spacing as needed
          child: Container(
            width: 30.0, // Image diameter
            height: 30.0, // Image diameter
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/sampleProfile.png'),
              ),
            ),
          ),
        ),
        // MessageBox for Additional Info
        Expanded(
          child: MessageBox(context: context, text: additionalInfo),
        ),
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InfoButton(
            context: context,
            text: 'Ask for more info',
            icon: FeatherIcons.messageCircle,
            iconColor: CupertinoColors.label.resolveFrom(context),
            onPressed: () {
              // Implement action for "Ask for more info"
            },
          ),
          SizedBox(width: 10), // Spacing between buttons
          InfoButton(
            context: context,
            text: 'Navigate to this Place',
            icon: FeatherIcons.arrowUpRight,
            iconColor: CupertinoColors.label.resolveFrom(context),
            onPressed: () {
              // Implement action for "Navigate to this Place"
            },
          ),
        ],
      ),
    );
  }
}

class CustomInfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomInfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.55,
              ),
            ),
          ),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color:
                    CupertinoColors.label.resolveFrom(context).withOpacity(0.6),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Continue with MessageBox, InfoButton, AllergensSection, and other widget classes.
class MessageBox extends StatelessWidget {
  final BuildContext context;
  final String text;

  const MessageBox({Key? key, required this.context, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.start, // Align text to the leading edge
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.48,
        ),
      ),
    );
  }
}

class InfoButton extends StatelessWidget {
  final BuildContext context;
  final String text;
  final IconData icon;
  final Color iconColor; // New color parameter for the icon
  final VoidCallback onPressed;

  const InfoButton({
    Key? key,
    required this.context,
    required this.text,
    required this.icon,
    required this.iconColor, // Include icon color in the constructor
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CupertinoColors.quaternarySystemFill.resolveFrom(context),
      borderRadius: BorderRadius.circular(100),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor), // Use the iconColor here
          SizedBox(width: 8), // Space between icon and text
          Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.48,
            ),
          ),
        ],
      ),
    );
  }
}

class AllergensSection extends StatelessWidget {
  final List<String> allergens;

  const AllergensSection({Key? key, required this.allergens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Allergens',
            style: TextStyle(
              fontSize: 20,
              color: CupertinoColors.label.resolveFrom(context),
              letterSpacing: -0.70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color:
                  CupertinoColors.tertiarySystemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8.0, // Space between the allergens
              runSpacing: 8.0, // Space between the lines
              children: allergens
                  .map((allergen) => _buildAllergenRow(allergen, context))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergenRow(String allergen, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('• ',
            style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        Expanded(
            child: Text(
          allergen,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.label.resolveFrom(context),
            letterSpacing: -0.55,
            fontWeight: FontWeight.w500,
          ),
        )),
      ],
    );
  }
}

// class ReserveButton extends StatelessWidget {
//   final bool isReserved;

//   const ReserveButton({Key? key, required this.isReserved}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48, // Set the height of the button
//       decoration: BoxDecoration(
//         color: isReserved
//             ? CupertinoColors.systemGrey
//             : CupertinoDynamicColor.resolve(accentColor, context),
//         borderRadius: BorderRadius.circular(100), // Rounded corners
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x19000000),
//             blurRadius: 20,
//             offset: Offset(0, 0),
//           ),
//         ],
//       ),
//       child: CupertinoButton(
//         padding: EdgeInsets
//             .zero, // Remove padding since we are using a Container for styling
//         child: Text(
//           isReserved
//               ? 'Reserved'
//               : 'Reserve', // Change button text based on state
//           style: TextStyle(
//             color: CupertinoColors.white, // Text color
//             fontSize: 18, // Text size
//             letterSpacing: -0.45, // Text spacing
//             fontWeight: FontWeight.w600, // Text weight
//           ),
//         ),
//         onPressed: isReserved
//             ? null
//             : () {
//                 // TODO: Add reservation logic here
//               },
//       ),
//     );
//   }
// }

class ReserveButton extends StatefulWidget {
  final bool isReserved;
  final VoidCallback? onPressed;

  const ReserveButton({
    Key? key,
    required this.isReserved,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // Set the height of the button
      decoration: BoxDecoration(
        color: isReserved
            ? CupertinoColors.systemGrey
            : CupertinoDynamicColor.resolve(accentColor, context),
        borderRadius: BorderRadius.circular(100), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          isReserved ? 'Reserved' : 'Reserve',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: -0.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: isReserved
            ? null
            : () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => DoneePath()),
                );
              },
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
