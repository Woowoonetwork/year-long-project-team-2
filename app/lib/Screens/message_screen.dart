import 'package:FoodHood/Components/chat_bubble.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/profile_screen.dart';
import 'package:FoodHood/Services/MessageService.dart';
import 'package:FoodHood/Services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatelessWidget {
  final List<String> recommendedMessages = [
    "Sure, see you then!",
    "On my way.",
    "Can we reschedule?",
    "Let me check my calendar.",
    "Running late, sorry!",
  ];
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final String receiverID;

  final MessageService messageService = MessageService();
  final AuthService authService = AuthService();

  MessageScreen({
    Key? key,
    required this.receiverID,
  });

  void sendMessage() async {
    final message = messageController.text;
    if (message.isNotEmpty) {
      await messageService.sendMessage(receiverID, message);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      body: SafeArea(child: _buildPageContent(context)),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: _buildMessageList(context)),
        _buildMessageInput(context),
      ],
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return FutureBuilder<String?>(
      future: authService.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        final senderID = snapshot.data;
        if (senderID == null) {
          return const Text("User ID not found.");
        }
        return StreamBuilder<QuerySnapshot>(
          stream: messageService.getMessages(senderID, receiverID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("No messages found.");
            }
            return ListView(
              controller: scrollController,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return _buildMessageItem(document, senderID, context);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(
      DocumentSnapshot document, String senderID, BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == senderID;
    return ChatBubble(message: data['message']
    , isCurrentUser: isCurrentUser);
  }

  Future<String> getReceiverName() async {
    var receiverData = await messageService.getReceiverData(receiverID);
    return receiverData["firstName"] + " " + receiverData["lastName"];
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: CupertinoButton(
        child: Icon(FeatherIcons.chevronLeft,
            size: 24, color: CupertinoColors.label.resolveFrom(context)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      centerTitle: false,
      title: GestureDetector(
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (context) => ProfileScreen())),
        child: FutureBuilder<String>(
          future: getReceiverName(), // Asynchronously get the receiver's name
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...",
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context)));
            } else if (snapshot.hasError) {
              return Text("Error",
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context)));
            } else {
              return Text(snapshot.data ?? "User",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context)));
            }
          },
        ),
      ),
      actions: [
        Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: CupertinoColors.activeGreen, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickMessageSuggestions(context),
          Container(
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(18.0)),
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Message Harry",
                hintStyle: TextStyle(
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w500,
                    color:
                        CupertinoColors.placeholderText.resolveFrom(context)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                suffixIcon: GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(FeatherIcons.arrowUp,
                        size: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMessageSuggestions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedMessages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => messageController.text = recommendedMessages[index],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color:
                      CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(100)),
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
}
