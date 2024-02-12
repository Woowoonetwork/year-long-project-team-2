import 'package:FoodHood/Screens/message_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/foodAppBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:FoodHood/Models/PostDetailViewModel.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:FoodHood/Components/cupertinosnackbar.dart';
import 'package:FoodHood/Screens/donee_pathway_uno.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/Screens/public_profile_screen.dart';

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
  late String userID;

  // Method to initialize userID
  void initializeUserId() {
    final user = FirebaseAuth.instance.currentUser;
    userID = user?.uid ?? 'default uid'; // Initialize userId here
  }

  @override
  void initState() {
    super.initState();

    initializeUserId();

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
                        onFavoritePressed: _handleFavoritePressed,
                        imageUrl: viewModel.imageUrl, // Pass the imageUrl here
// Pass the callback function
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
              padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: ReserveButton(
                      isReserved: false,
                      postId: widget.postId,
                      userId: userID,
                    ),
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
        '"${viewModel.title}" has been added to your bookmarks',
        accentColor,
        Icon(FeatherIcons.check, color: Colors.white),
        _reverseAnimation, // Pass _reverseAnimation as the callback
      );
    } else {
      await viewModel.unsavePost(widget.postId);
      showCupertinoSnackbar(
        context,
        '"${viewModel.title}" has been removed from your bookmarks',
        yellow,
        Icon(FeatherIcons.x, color: Colors.white),
        _reverseAnimation,
      );
    }
  }

  void _reverseAnimation() {
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

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
      onSnackbarClosed();
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
                height: 1.2,
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
          color: color.computeLuminance() > 0.5
              ? CupertinoColors.black
              : CupertinoColors.white,
          fontSize: 10,
          letterSpacing: -0.40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return InfoCardsRow(
      expirationDate: viewModel.expirationDate,
      pickupTime: viewModel.pickupTime,
      allergens: viewModel.allergens,
    );
  }

  Widget _buildPickupInformation() {
    LatLng? pickupCoordinates = viewModel.pickupLatLng;
    return PickupInformation(
      pickupTime:
          DateFormat('EEE, MMM d, ' 'h:mm a').format(viewModel.pickupTime),
      pickupLocation: viewModel.pickupLocation,
      meetingPoint: '330, 1130 Trello Way\nKelowna, BC\nV1V 5E0',
      additionalInfo: viewModel.pickupInstructions,
      locationCoordinates: pickupCoordinates,
      viewModel: viewModel,
    );
  }

  Widget _buildAllergensSection() {
    List<String> allergenList = viewModel.allergens.split(', ');
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
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => PublicProfileScreen()),
        );
      },
      child: Row(
        children: [
          IconPlaceholder(imageUrl: viewModel.profileURL),
          const SizedBox(width: 8),
          Expanded(
            child: CombinedTexts(
              firstName: firstName,
              lastName: lastName,
              postTimestamp: postTimestamp,
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    ));
  }
}

class IconPlaceholder extends StatelessWidget {
  final String imageUrl; // Parameter for the image URL

  IconPlaceholder({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   image: DecorationImage(
      //     fit: BoxFit.cover,
      //     // Dynamically load image from assets or network
      //     image: _loadImage(imageUrl),
      //   ),
      // ),
      child: ClipOval(
        child: // use cached network image to load the image
            CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => CupertinoActivityIndicator(),
          errorWidget: (context, url, error) =>
              //AssetImage('assets/images/sampleProfile.png');
              Image.asset('assets/images/sampleProfile.png'),
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
    required this.viewModel,
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
        RatingText(),
      ],
    );
  }
}

class InfoText extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime postTimestamp;
  final PostDetailViewModel viewModel;

  const InfoText({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.postTimestamp,
    required this.viewModel,
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
            text: 'Posted ${viewModel.timeAgoSinceDate(postTimestamp)}',
            style: TextStyle(letterSpacing: -0.48),
          ),
        ],
      ),
    );
  }
}

class RatingText extends StatelessWidget {
  final PostDetailViewModel viewModel = PostDetailViewModel('default');

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
          '${viewModel.rating} Rating',
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
            color: blue,
          ),
          const SizedBox(width: 16),
          buildInfoCard(
            icon: FeatherIcons.alertCircle,
            title: 'Allergens',
            subtitle: allergens.isEmpty ? 'None' : allergens,
            context: context,
            color: yellow,
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

class PickupInformation extends StatelessWidget {
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
    final LatLng? locationCoordinates = viewModel.pickupLatLng;

    if (locationCoordinates != null) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          height: 188.0,
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
        child: Text('Map Placeholder'),
      );
    }
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInfoTile(title: 'Pickup Time', subtitle: pickupTime),
        CustomInfoTile(
            title: 'Pickup Location', subtitle: viewModel.pickupLocation),
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
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Container(
            width: 30.0,
            height: 30.0,
            // use cached network image to load the image
            child: //clipoval
                //   CachedNetworkImage(
                // imageUrl: viewModel.profileURL,
                // fit: BoxFit.cover,
                // placeholder: (context, url) => CupertinoActivityIndicator(),
                // errorWidget: (context, url, error) => Image.asset(
                //   'assets/images/sampleProfile.png',
                //   fit: BoxFit.cover,
                // ),
                ClipOval(
              child: CachedNetworkImage(
                imageUrl: viewModel.profileURL,
                fit: BoxFit.cover,
                placeholder: (context, url) => CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/sampleProfile.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
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
              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        MessageScreenPage()), // Adjust according to your MessageScreenPage's constructor
              );
            },
          ),
          SizedBox(width: 10),
          InfoButton(
            context: context,
            text: 'Navigate to this Place',
            icon: FeatherIcons.arrowUpRight,
            iconColor: CupertinoColors.label.resolveFrom(context),
            onPressed: () {},
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
        textAlign: TextAlign.start,
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
  final Color iconColor;
  final VoidCallback onPressed;

  const InfoButton({
    Key? key,
    required this.context,
    required this.text,
    required this.icon,
    required this.iconColor,
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
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: 8),
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

class ReserveButton extends StatefulWidget {
  final bool isReserved;
  final String postId;
  final String userId;

  const ReserveButton({
    Key? key,
    required this.isReserved,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  _ReserveButtonState createState() => _ReserveButtonState();
}

class _ReserveButtonState extends State<ReserveButton> {
  bool _isReserved = false;

  @override
  void initState() {
    super.initState();
    _isReserved = widget.isReserved;
  }

  void _handleReservation() async {
    if (!_isReserved) {
      try {
        await FirebaseFirestore.instance
            .collection('post_details')
            .doc(widget.postId)
            .update({'reserved_by': widget.userId, 'post_status': "pending"});
        setState(() {
          _isReserved = true;
        });
      } catch (error) {
        print('Error reserving post: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reserve post. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoButton(
        color: _isReserved
            ? accentColor.resolveFrom(context).withOpacity(0.2)
            : accentColor,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(14),
        child: Text(
          _isReserved ? 'Reserved' : 'Reserve',
          style: TextStyle(
            color: _isReserved ? accentColor : CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.90,
          ),
        ),
        onPressed: _isReserved
            ? null
            : () {
                _handleReservation();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => DoneePath(
                            postId: widget.postId,
                          )),
                );
              },
      ),
    );
  }
}
