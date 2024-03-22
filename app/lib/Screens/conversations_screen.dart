import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/message_screen.dart';
import 'package:FoodHood/Services/AuthService.dart';
import 'package:FoodHood/Services/MessageService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConversationsScreen extends StatelessWidget {
  final MessageService messageService = MessageService();

  final AuthService authService = AuthService();
  ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            transitionBetweenRoutes: true,
            backgroundColor: backgroundColor,
            largeTitle: Text('Messages'),
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'Back',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'Compose',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              onPressed: () {},
            ),
          ),
          _buildMessageList(context),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
      BuildContext context, Map<String, dynamic> userData, String userID) {
    String profileURL = userData["profileImagePath"] ?? '';
    String title =
        '${userData["firstName"] ?? ''} ${userData["lastName"] ?? ''}'.trim();

    return CupertinoListTile(
      profileURL: profileURL,
      title: title,
      messagePreview: "",
      time: "",
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => MessageScreen(
              receiverID: userID,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('An error occurred. Please try again later.'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Here we get the document snapshot
                var documentSnapshot = snapshot.data!.docs[index];
                // And here we get the document ID
                var userID = documentSnapshot.id;
                // Then we get the user data
                var userData = documentSnapshot.data() as Map<String, dynamic>;

                return _buildMessageCard(context, userData, userID);
              },
              childCount: snapshot.data!.docs.length,
            ),
          );
        } else {
          // Handle the case when there is no data
          return SliverFillRemaining(
            child: Center(
              child: Text('No messages found.'),
            ),
          );
        }
      },
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final String profileURL;
  final String title;
  final String messagePreview;
  final String time;
  final VoidCallback onTap;

  const CupertinoListTile({
    Key? key,
    required this.profileURL,
    required this.title,
    required this.messagePreview,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: CupertinoColors.systemGrey4.resolveFrom(context),
              backgroundImage: CachedNetworkImageProvider(profileURL),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.label.resolveFrom(context),
                        fontWeight: FontWeight.w600,
                      )),
                  Text(messagePreview,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      )),
                ],
              ),
            ),
            Text(time,
                style: TextStyle(
                    fontSize: 14,
                    color:
                        CupertinoColors.secondaryLabel.resolveFrom(context))),
            Icon(CupertinoIcons.forward,
                color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          ],
        ),
      ),
    );
  }
}
