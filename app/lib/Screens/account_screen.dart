import 'package:FoodHood/Screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:FoodHood/Components/profile_card.dart';
import 'package:FoodHood/Components/order_card.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoodHood/text_scale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

const double _defaultTextFontSize = 16.0;
const double _defaultTabTextFontSize = 14.0;

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int segmentedControlGroupValue = 0;
  List<Widget> activeOrders = [];
  List<OrderCard> pastOrders = [];
  late double _textScaleFactor;
  late double adjustedTextFontSize;
  late double adjustedTabTextFontSize;

  @override
  void initState() {
    super.initState();
    setUpPostStreamListener();
    _textScaleFactor =
        Provider.of<TextScaleProvider>(context, listen: false).textScaleFactor;
    _updateAdjustedFontSize();
  }

  void setUpPostStreamListener() {
    final String currentUserUID = FirebaseAuth.instance.currentUser?.uid ?? '';
    FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .where('user_id', isEqualTo: currentUserUID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var activeDocs = snapshot.docs
            .where((doc) => doc['post_status'] != 'delivered')
            .toList();
        var pastDocs = snapshot.docs
            .where((doc) => doc['post_status'] == 'delivered')
            .toList();
        if (mounted) {
          updateActiveOrders(activeDocs);
          updatePastOrders(pastDocs);
        }
      }
    });
  }

  void updatePastOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      pastOrders = documents
          .map((doc) =>
              createOrderCard(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  void _updateAdjustedFontSize() {
    adjustedTextFontSize = _defaultTextFontSize * _textScaleFactor;
    adjustedTabTextFontSize = _defaultTabTextFontSize * _textScaleFactor;
  }

  void updateActiveOrders(List<QueryDocumentSnapshot> documents) {
    setState(() {
      activeOrders = documents.map((doc) {
        return createOrderCard(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  OrderCard createOrderCard(Map<String, dynamic> documentData, String postId) {
    String title = documentData['title'] ?? 'No Title';
    List<String> tags = documentData['categories'].split(',');
    DateTime createdAt = (documentData['post_timestamp'] as Timestamp).toDate();
    List<Map<String, String>> imagesWithAltText = [];
    if (documentData.containsKey('images') && documentData['images'] is List) {
      imagesWithAltText = List<Map<String, String>>.from(
        (documentData['images'] as List).map((image) {
          return {
            'url': (image['url'] as String?) ?? '',
            'alt_text': (image['alt_text'] as String?) ?? '',
          };
        }),
      );
    }
    return OrderCard(
        title: title,
        tags: tags,
        orderInfo: 'Posted on ${DateFormat('MMMM dd, yyyy').format(createdAt)}',
        postId: postId,
        onTap: (id) {},
        imagesWithAltText: imagesWithAltText,
        orderState: getOrderState(documentData['post_status'] ?? ''));
  }

  OrderState getOrderState(String status) {
    return OrderState.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => OrderState.pending);
  }

  @override
  Widget build(BuildContext context) {
    _textScaleFactor = Provider.of<TextScaleProvider>(context).textScaleFactor;
    _updateAdjustedFontSize();
    final Map<int, Widget> myTabs = {
      0: Text('Active Orders',
          style: TextStyle(
              fontSize: adjustedTabTextFontSize, fontWeight: FontWeight.w500)),
      1: Text('Past Orders',
          style: TextStyle(
              fontSize: adjustedTabTextFontSize, fontWeight: FontWeight.w500))
    };
    return CupertinoPageScaffold(
        backgroundColor: groupedBackgroundColor,
        child: SafeArea(
            child: CustomScrollView(slivers: <Widget>[
          _buildNavigationBar(),
          SliverToBoxAdapter(child: ProfileCard()),
          _buildSegmentControl(myTabs),
          _buildOrdersContent(segmentedControlGroupValue)
        ])));
  }

  CupertinoSliverNavigationBar _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
        transitionBetweenRoutes: false,
        backgroundColor:
            CupertinoDynamicColor.resolve(groupedBackgroundColor, context)
                .withOpacity(0.8),
        largeTitle: Text('Account'),
        trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Settings',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                    letterSpacing: -0.6)),
            onPressed: () => {
                  HapticFeedback.selectionClick(),
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => SettingsScreen()))
                }),
        border: Border(bottom: BorderSide.none),
        stretch: true);
  }

  SliverToBoxAdapter _buildSegmentControl(Map<int, Widget> myTabs) {
    return SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: CupertinoSlidingSegmentedControl<int>(
                children: myTabs,
                onValueChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => segmentedControlGroupValue = newValue);
                  }
                },
                groupValue: segmentedControlGroupValue)));
  }

  Widget _buildOrdersContent(int segmentedValue) {
    return segmentedValue == 0
        ? (activeOrders.isNotEmpty
            ? _buildActiveOrdersSliver()
            : _buildPlaceholderText())
        : (pastOrders.isNotEmpty
            ? _buildPastOrdersSliver()
            : _buildPlaceholderText());
  }

  SliverList _buildActiveOrdersSliver() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: activeOrders[index]),
            childCount: activeOrders.length));
  }

  SliverList _buildPastOrdersSliver() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
                padding: const EdgeInsets.all(16.0), child: pastOrders[index]),
            childCount: pastOrders.length));
  }

  SliverFillRemaining _buildPlaceholderText() {
    return SliverFillRemaining(
        hasScrollBody: false,
        child: SizedBox(
            height: 50,
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Icon(FeatherIcons.shoppingBag,
                      size: 40, color: CupertinoColors.systemGrey),
                  SizedBox(height: 20),
                  Text('No orders available',
                      style: TextStyle(
                          fontSize: adjustedTextFontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.6,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context)),
                      textAlign: TextAlign.center)
                ]))));
  }
}
