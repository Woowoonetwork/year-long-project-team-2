import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Components/post_card.dart';
import 'package:FoodHood/Screens/create_post.dart';
import 'package:FoodHood/firestore_service.dart';
import 'package:feather_icons/feather_icons.dart';
import '../components.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Widget> postCards = [];
  Map<String, Color> tagColors = {};
  StreamSubscription<QuerySnapshot>? postsSubscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initListeners();
    _loadInitialPosts();
  }

  void _initListeners() {
    textController.addListener(_onSearchTextChanged);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _loadInitialPosts() {
    setState(() => isLoading = true);
    postsSubscription = FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (mounted) {
        postCards = await _processSnapshot(snapshot);
        setState(() => isLoading = false);
      }
    });
  }

  Future<List<Widget>> _processSnapshot(QuerySnapshot snapshot) async {
    List<Widget> cards = [];
    for (var doc in snapshot.docs) {
      cards.add(await _buildPostCard(doc));
    }
    cards.add(SizedBox(height: 100));
    return cards;
  }

  Future<Widget> _buildPostCard(QueryDocumentSnapshot document) async {
    var data = document.data() as Map<String, dynamic>?;
    if (data == null) {
      return SizedBox.shrink(); // Return an empty widget if data is null
    }

    List<String> tags = (data['categories'] as String?)
            ?.split(',')
            ?.map((tag) => tag.trim())
            ?.toList() ??
        [];
    List<Color> assignedColors = tags
        .map((tag) => tagColors.putIfAbsent(tag, () => _getRandomColor()))
        .toList();
    var userData = await readDocument(
        collectionName: 'user', docName: data['user_id'] ?? 'Unknown');
    var createdAt =
        (data['post_timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: PostCard(
        imageLocation: data['image_url'] ?? '',
        title: data['title'] ?? 'No Title',
        tags: tags,
        tagColors: assignedColors,
        firstname: userData?['firstName'] ?? 'Unknown',
        lastname: userData?['lastName'] ?? 'Unknown',
        timeAgo: timeAgoSinceDate(createdAt),
        onTap: (postId) => setState(() => {}),
        postId: document.id,
        profileURL: userData?['profileImagePath'] ??
            'assets/images/sampleProfile.png', // Fallback to default image if null
      ),
    );
  }

  @override
  void dispose() {
    textController.removeListener(_onSearchTextChanged);
    textController.dispose();
    _focusNode.dispose();
    postsSubscription?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged() async {
    var searchString = textController.text.toLowerCase();
    if (mounted) {
      postCards = await fetchPosts(searchString);
      setState(() {});
    }
  }

  Future<List<Widget>> fetchPosts(String searchString) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('post_details')
        .orderBy('post_timestamp', descending: true)
        .get();

    // Correcting the return type by using Future.wait
    var futures = querySnapshot.docs
        .where((doc) => _matchesSearchString(doc, searchString))
        .map((doc) => _buildPostCard(doc))
        .toList();

    return await Future.wait(futures);
  }

  bool _matchesSearchString(QueryDocumentSnapshot doc, String searchString) {
    var data = doc.data() as Map<String, dynamic>;
    var title = data['title']?.toLowerCase() ?? '';
    var tags = List<String>.from(
        data['categories'].split(',').map((tag) => tag.toLowerCase()));
    return title.contains(searchString) ||
        tags.any((tag) => tag.contains(searchString));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: groupedBackgroundColor,
      child: Stack(
        children: [
          CustomScrollView(slivers: <Widget>[
            buildMainNavigationBar(context, 'Discover'),
            SliverToBoxAdapter(
                child: Column(children: <Widget>[
              _buildSearchBar(context),
              SizedBox(height: 16),
              _buildCategoryButtons(),
              SizedBox(height: 16)
            ])),
            isLoading ? _buildLoadingSliver(context) : _buildPostListSliver(),
          ]),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildLoadingSliver(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            CupertinoActivityIndicator(),
            SizedBox(height: 10),
            Text('Loading',
                style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context)))
          ])),
    );
  }

  Widget _buildPostListSliver() {
    if (postCards.isEmpty) {
      // Display message and icon when there are no posts
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FeatherIcons.search,
                size: 42,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              SizedBox(height: 20),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Display the list of post cards
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => postCards[index],
          childCount: postCards.length,
        ),
      );
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    bool isFocused = _focusNode.hasFocus;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: _buildSearchTextField(context)),
          if (!isFocused) SizedBox(width: 10),
          if (!isFocused) _buildFilterButton()
        ]),
      ),
    );
  }

  CupertinoSearchTextField _buildSearchTextField(BuildContext context) {
    return CupertinoSearchTextField(
      prefixIcon: Container(
        margin: EdgeInsets.only(left: 6.0, top: 2.0),
        child: Icon(
          FeatherIcons.search,
          size: 18.0,
        ),
      ),
      placeholderStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
      suffixIcon: Icon(FeatherIcons.x,
          color: CupertinoColors.secondaryLabel.resolveFrom(context), size: 20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      style: TextStyle(
          fontSize: 18, color: CupertinoColors.label.resolveFrom(context)),
      backgroundColor: CupertinoColors.tertiarySystemBackground,
      controller: textController,
      placeholder: 'Search',
      onChanged: (value) => _onSearchTextChanged(),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: 37,
      width: 37,
      decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10)),
      child: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(FeatherIcons.filter,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              size: 20),
          onPressed: () {}),
    );
  }

  Widget _buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(spacing: 8.0, children: <Widget>[
          _buildCategoryButton('All', accentColor),
          _buildCategoryButton('Vegan', yellow),
          _buildCategoryButton('Italian', orange),
          _buildCategoryButton('Halal', blue),
          _buildCategoryButton('Vegetarian', babyPink),
          _buildCategoryButton('Indian', orange)
        ]),
      ),
    );
  }

  Widget _buildCategoryButton(String title, Color color) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 60, maxHeight: 40),
      child: CupertinoButton(
        child: Text(title,
            style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                letterSpacing: -0.6,
                fontWeight: FontWeight.w600)),
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        borderRadius: BorderRadius.circular(100),
        onPressed: () {},
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      bottom: 100.0,
      right: 16.0,
      child: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color(0x19000000), blurRadius: 20, offset: Offset(0, 0))
        ], shape: BoxShape.circle),
        child: CupertinoButton(
          onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => CreatePostScreen())),
          child:
              Icon(FeatherIcons.plus, color: CupertinoColors.white, size: 30),
          color: accentColor,
          padding: EdgeInsets.all(16.0),
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
    );
  }

  String timeAgoSinceDate(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 7)
      return DateFormat('on MMMM dd, yyyy').format(dateTime);
    if (duration.inDays >= 1)
      return '${duration.inDays} day${duration.inDays > 1 ? "s" : ""} ago';
    if (duration.inHours >= 1)
      return '${duration.inHours} hour${duration.inHours > 1 ? "s" : ""} ago';
    if (duration.inMinutes >= 1)
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""} ago';
    return 'Just now';
  }

  Color _getRandomColor() {
    var colors = [yellow, orange, blue, babyPink];
    return colors[math.Random().nextInt(colors.length)];
  }
}
