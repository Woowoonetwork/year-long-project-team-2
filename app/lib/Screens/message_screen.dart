import 'package:FoodHood/Components/chat_bubble.dart';
import 'package:FoodHood/Components/chat_input.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/profile_screen.dart';
import 'package:FoodHood/Services/AuthService.dart';
import 'package:FoodHood/Services/MessageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String receiverID;

  const MessageScreen({super.key, required this.receiverID});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  late MessageService messageService;
  late AuthService authService;
  late Future<String> receiverName;

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      body: SafeArea(child: _buildPageContent(context)),
    );
  }

  Future<String> getReceiverName() async {
    var receiverData = await messageService.getReceiverData(widget.receiverID);
    return receiverData["firstName"] + " " + receiverData["lastName"];
  }

  @override
  void initState() {
    super.initState();
    messageService = MessageService();
    authService = AuthService();
    receiverName = getReceiverName();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), scrollDown);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => scrollDown(),
      );
    });

    setupMessageListener();
  }

  void setupMessageListener() async {
    // Fetch the user ID asynchronously
    final userId = await authService.getUserId();

    // Once you have the userId, set up the listener for new messages
    if (userId != null) {
      // Check if userId is not null
      messageService
          .getMessages(userId, widget.receiverID)
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          scrollDown();
        }
      });
    }
  }

  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void sendMessage() async {
    final message = messageController.text;
    if (message.isNotEmpty) {
      await messageService.sendMessage(widget.receiverID, message);
      messageController.clear();
      scrollDown();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: CupertinoButton(
          child: Icon(FeatherIcons.chevronLeft,
              size: 24, color: CupertinoColors.label.resolveFrom(context)),
          onPressed: () => Navigator.of(context).pop()),
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      centerTitle: false,
      title: GestureDetector(
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (context) => ProfileScreen())),
        child: FutureBuilder<String>(
          future: receiverName,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context)));
            } else {
              return Text("",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context)));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessageItem(
      DocumentSnapshot document, String senderID, BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == senderID;
    return ChatBubble(message: data['message'], isCurrentUser: isCurrentUser);
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
          stream: messageService.getMessages(senderID, widget.receiverID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text("No messages found.",
                  style: TextStyle(
                      letterSpacing: -0.4,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context)));
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

  Widget _buildPageContent(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: _buildMessageList(context)),
        FutureBuilder<String>(
          future: receiverName,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text("Error loading name");
            } else {
              return MessageInputRow(
                  firstName: snapshot.data?.split(' ').first ?? '',
                  messageController: messageController,
                  sendMessage: sendMessage,
                  focusNode: focusNode);
            }
          },
        ),
      ],
    );
  }
}
