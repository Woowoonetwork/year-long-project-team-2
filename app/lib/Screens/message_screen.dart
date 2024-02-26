import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/public_profile_screen.dart';

class MessageScreenPage extends StatefulWidget {
  final String uid2;

  MessageScreenPage({required this.uid2});

  @override
  _MessageScreenPageState createState() => _MessageScreenPageState();
}

class _MessageScreenPageState extends State<MessageScreenPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> messages = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _initializeMessagingDocument(); // Step 3
    _getUserID(); // Fetch the user ID
  }

  // Step 2: Fetch the user ID
  void _getUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  // Step 3: Initialize the messaging document in Firestore
  void _initializeMessagingDocument() {
    // Concatenate userId and uid2 alphabetically
    String concatenatedString =
        [userId, widget.uid2].toList()..sort().join();

    // Create a new document in 'messaging' collection
    FirebaseFirestore.instance.collection('messaging').doc(concatenatedString).set({});

    // Step 5: Listen for updates to the messaging document
    FirebaseFirestore.instance.collection('messaging').doc(concatenatedString).snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        // Update messages when the document is updated
        setState(() {
          messages = List<Map<String, dynamic>>.from(docSnapshot.data()?['messages'] ?? []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: CupertinoDynamicColor.resolve(
        backgroundColor,
        context,
      ),
      body: SafeArea(
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildMessagesList(),
        ),
        _buildMessageInput(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      leading: _buildBackButton(),
      backgroundColor: CupertinoDynamicColor.resolve(
        backgroundColor,
        context,
      ),
      centerTitle: false,
      title: _buildContactName(),
      actions: [_buildTrailingItems()],
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildTrailingItems() {
    return Container(
      padding: EdgeInsets.only(right: 16),
      child: Row(
        children: [
          _buildOnlineIndicator(),
          _buildLastSeenText(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(FeatherIcons.chevronLeft,
          size: 22, color: CupertinoColors.label.resolveFrom(context)),
      onPressed: () => Navigator.of(context).pop(),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
    );
  }

  Widget _buildContactName() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => PublicProfileScreen()),
        );
      },
      child: Text(
        'Harry Styles',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: -1.3,
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.activeGreen,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLastSeenText() {
    return Text(
      'Last seen a minute ago',
      style: TextStyle(
        fontSize: 14,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMessagesList() {
    int lastReadMessageIndex = messages
        .lastIndexWhere((message) => message["sender"] == userId);

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,

        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          bool isCurrentUser = message["sender"] == userId;

          return Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _buildMessage(
                isCurrentUser
                    ? "You: ${message["text"]}"
                    : message["text"],
              ),
              if (isCurrentUser)
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    right: 16,
                  ),
                  child: Text(
                    "Sent ${message["timestamp"]}", // Step 6
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        left: 0,
        right: 0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.6,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }

  Widget _buildQuickMessageSuggestions() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedMessages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _quickMessageTap(recommendedMessages[index]),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  recommendedMessages[index],
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _quickMessageTap(String message) {
    _messageController.text = message;
  }

  Widget _buildMessageInput() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickMessageSuggestions(),
          Container(
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors.label.resolveFrom(context),
                letterSpacing: -0.6,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "Message Harry",
                hintStyle: TextStyle(
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.placeholderText.resolveFrom(context),
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                suffixIcon: GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FeatherIcons.arrowUp,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Modify _sendMessage function
  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // Step 4: Add new message to Firestore
      FirebaseFirestore.instance
          .collection('messaging')
          .doc([userId, widget.uid2].toList()..sort().join())
          .update({
        'messages': FieldValue.arrayUnion([
          {
            "text": messageText,
            "sender": userId,
            "timestamp": DateTime.now().toString(),
          }
        ]),
      });

      setState(() {
        messages.add({
          "text": messageText,
          "sender": userId,
          "timestamp": DateTime.now().toString(),
        });
      });
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          messages.add({
            "text": "Auto-reply to: $messageText",
            "sender": widget.uid2,
            "timestamp": DateTime.now().toString(),
          });

          if (messages.isNotEmpty) {
            messages[messages.length - 2]["read"] = true;
          }
        });

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
