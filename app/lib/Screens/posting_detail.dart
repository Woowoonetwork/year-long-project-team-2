import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';

//import status

class PostDetailView extends StatefulWidget {
  @override
  _PostDetailViewState createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  String firstName = '';
  String lastName = '';
  String allergens = '';
  String description = '';
  DateTime pickup_time = DateTime.now();
  DateTime expiration_date = DateTime.now();
  DateTime parsedExpirationDate = DateTime.now();
  String pickup_location = '';
  String pickup_instructions = '';
  String title = '';
  List<dynamic> reviews = [];
  double rating = 0.0;
  String userid = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      Map<String, dynamic>? documentData = await readDocument(
        collectionName: 'post_details',
        docName: '09a03b03-d37c-40d3-bd1c-36eed27113a5',
      );

      if (documentData != null) {
        setState(() {
          allergens = documentData['allergens'] ?? '';
          description = documentData['description'] ?? '';
          title = documentData['title'] ?? '';
          pickup_instructions = documentData['pickup_instructions'] ?? '';
          userid = documentData['user_id'] ?? '';

          try {
            pickup_time = DateTime.parse(documentData['pickup_time']);
          } catch (e) {
            pickup_time = DateTime.now();
          }
          try {
            //DateTime createdAt =
            // (documentData['post_timestamp'] as Timestamp).toDate();
            print(documentData['expiration_date']);
          } catch (e) {}

          pickup_location = documentData['pickup_location'] ?? '';
          rating = documentData['rating'] ?? 0.0;
        });
      } else {
        print('Document does not exist or is null.');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }

    try {
      Map<String, dynamic>? documentData = await readDocument(
        collectionName: 'user',
        docName: userid,
      );

      if (documentData != null) {
        setState(() {
          firstName = documentData['firstName'];
          lastName = documentData['lastName'];
        });
      } else {
        print('Document does not exist or is null.');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(FeatherIcons.chevronLeft,
                size: 28, color: CupertinoColors.label)),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(FeatherIcons.heart,
                size: 22, color: CupertinoColors.systemRed),
            SizedBox(width: 15),
            Icon(FeatherIcons.share,
                size: 22, color: CupertinoColors.systemBlue)
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const Image(
                image: AssetImage('assets/images/sampleFoodPic.png'),
                fit: BoxFit.fill),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.34,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      AvailabilityIndicator(isReserved: false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(firstName: firstName, lastName: lastName),
                  const SizedBox(height: 16),
                  InfoCardsRow(
                    expirationDate: parsedExpirationDate,
                    pickupTime: pickup_time,
                    allergens: allergens,
                  ),
                  PickupInformation(
                    pickup_instructions: pickup_instructions,
                    pickup_location: pickup_location,
                  ),
                  const SizedBox(height: 16),
                  AllergensSection(allergens: allergens),
                  Center(
                    child: ReserveButton(
                      isReserved: false,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailabilityIndicator extends StatelessWidget {
  final bool isReserved;
  AvailabilityIndicator({required this.isReserved});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = isReserved
        ? CupertinoColors.systemRed.withOpacity(0.2)
        : CupertinoColors.activeGreen.withOpacity(0.2);

    Color circleColor =
        isReserved ? CupertinoColors.systemRed : CupertinoColors.activeGreen;

    String statusText = isReserved ? 'Reserved' : 'Available';

    return Container(
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 26,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            statusText,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.label,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class CombinedTexts extends StatelessWidget {
  final String firstName;
  final String lastName;

  CombinedTexts({required this.firstName, required this.lastName});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InfoText(
          firstName: firstName,
          lastName: lastName,
        ),
        SizedBox(width: 8),
        RatingText(),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String firstName;
  final String lastName;

  InfoRow({required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        children: [
          IconPlaceholder(),
          const SizedBox(width: 8),
          Expanded(
              child: CombinedTexts(
            firstName: firstName,
            lastName: lastName,
          )),
        ],
      ),
    );
  }
}

class IconPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGrey2,
        shape: BoxShape.circle,
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String firstName;
  final String lastName;

  InfoText({required this.firstName, required this.lastName});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: CupertinoColors.black.withOpacity(0.6),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        children: <TextSpan>[
          TextSpan(text: 'Prepared by $firstName $lastName'),
          const TextSpan(
              text: '   Posted 32 mins ago',
              style: TextStyle(letterSpacing: -0.48)),
        ],
      ),
    );
  }
}

class RatingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FeatherIcons.star,
          color: CupertinoColors.systemYellow,
          size: 16,
        ),
        const SizedBox(width: 2),
        Text(
          '5.0',
          style: TextStyle(
            color: CupertinoColors.black.withOpacity(0.6),
            fontSize: 12,
            fontFamily: 'Inter',
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

  InfoCardsRow({
    required this.expirationDate,
    required this.pickupTime,
    required this.allergens,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: buildInfoCard(
              icon: FeatherIcons.clock,
              title: 'Expiration Date',
              subtitle: DateFormat('yyyy-MM-dd HH:mm').format(expirationDate),
              context: context,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: buildInfoCard(
              icon: FeatherIcons.mapPin,
              title: 'Pickup Time',
              subtitle: 'Today, 12:03pm',
              context: context,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: buildInfoCard(
              icon: FeatherIcons.alertCircle,
              title: 'Allergens',
              subtitle: 'See below',
              context: context,
            ),
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
  }) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 100,
          maxWidth: 150,
          minHeight: 100,
          maxHeight: 150,
        ),
        child: CupertinoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: CupertinoColors.systemGrey),
              SizedBox(height: 8.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
            ],
          ),
        ));
  }
}

class PickupInformation extends StatelessWidget {
  final String pickup_instructions;
  final String pickup_location;
  PickupInformation(
      {required this.pickup_instructions, required this.pickup_location});

  @override
  Widget build(BuildContext context) {
    return CupertinoCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Information',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(pickup_instructions),
            const SizedBox(height: 16),
            Text(
              'Meeting Point',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(pickup_location),
          ],
        ),
      ),
    );
  }
}

class AllergensSection extends StatelessWidget {
  final String allergens;
  AllergensSection({
    required this.allergens,
  });
  @override
  Widget build(BuildContext context) {
    return CupertinoCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allergens',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(allergens),
          ],
        ),
      ),
    );
  }
}

class ReserveButton extends StatelessWidget {
  final bool isReserved;
  ReserveButton({required this.isReserved});
  @override
  Widget build(BuildContext context) {
    Color indicatorColor =
        isReserved ? CupertinoColors.systemGrey : CupertinoColors.activeBlue;
    Color textColor =
        isReserved ? CupertinoColors.white : CupertinoColors.white;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoButton(
        color: indicatorColor,
        child: Text('Reserve', style: TextStyle(color: textColor)),
        onPressed: isReserved
            ? null
            : () {
                // Add reserving logic here
              },
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class CupertinoCard extends StatelessWidget {
  final Widget child;

  const CupertinoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.5),
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

//backend beginning
