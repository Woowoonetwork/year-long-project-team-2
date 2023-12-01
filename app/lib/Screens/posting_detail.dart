import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:feather_icons/feather_icons.dart';

class PostDetailView extends StatelessWidget {
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
                size: 22, color: CupertinoColors.systemBlue) // Second item
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
                      const Expanded(
                        child: Text(
                          'Chicken and Rice',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.34,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      AvailabilityIndicator(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Succulent grilled chicken breast marinated in a zesty lemon-garlic sauce, served atop a bed of fluffy cilantro-lime rice. Accompanied by a side of steamed asparagus spears and drizzled with a tangy mango salsa.',
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(),
                  const SizedBox(height: 16),
                  PickupInformation(),
                  const SizedBox(height: 16),
                  AllergensSection(),
                  ReserveButton(),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.activeGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 26,
            decoration: const BoxDecoration(
              color: CupertinoColors.activeGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Available',
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

class InfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 386,
      height: 21,
      child: Row(
        children: [
          IconPlaceholder(),
          const SizedBox(width: 8),
          Expanded(child: InfoText()),
          const SizedBox(width: 8),
          RatingText(),
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
          const TextSpan(text: 'Prepared by Harry Styles'),
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
    return Text(
      '5.0 Rating',
      style: TextStyle(
        color: CupertinoColors.black.withOpacity(0.6),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        letterSpacing: -0.48,
      ),
    );
  }
}

class PickupInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Information',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          const Text('Today, 12:03pm'),
          const SizedBox(height: 16),
          Text(
            'Meeting Point',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          const Text('330, 1130 Trello Way\nKelowna, BC\nV1V 5E0'),
        ],
      ),
    );
  }
}

class AllergensSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allergens',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
              'Peanuts, Tree nuts (e.g., almonds, cashews, walnuts), Milk, Eggs, Soy'),
        ],
      ),
    );
  }
}

class ReserveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoButton.filled(
        child: const Text('Reserve'),
        onPressed: () {
          // Implement reservation logic
        },
      ),
    );
  }
}
