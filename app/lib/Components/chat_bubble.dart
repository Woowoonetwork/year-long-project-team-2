import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Services/MessageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final String conversationID; // Add this
  final String messageID; // And this

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.conversationID, // New
    required this.messageID, // New
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Widget? emojiOverlay;
  
  @override
  Widget build(BuildContext context) {
    DateTime date = widget.timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime messageDate = DateTime(date.year, date.month, date.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    final messageService = MessageService();

    String formattedDate;

    if (messageDate == today) {
      formattedDate = "Today, ${DateFormat('h:mm a').format(date)}";
    } else if (messageDate == yesterday) {
      formattedDate = "Yesterday, ${DateFormat('h:mm a').format(date)}";
    } else {
      formattedDate = DateFormat('MMM d, h:mm a').format(date);
    }
    return Align(
      alignment:
          widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: widget.isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Copy text',
                    icon: CupertinoIcons.doc_on_clipboard,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.message));
                    },
                  ),
                  const PullDownMenuDivider.large(),
                  const PullDownMenuTitle(title: Text('Reactions')),
                  PullDownMenuItem(
                    title: 'Like',
                    icon: CupertinoIcons.heart_fill,
                    iconColor: babyPink,
                    onTap: () {
                      messageService.reactToMessage(
                          widget.conversationID, widget.messageID, '❤️');
                      setState(() => emojiOverlay = Icon(
                            CupertinoIcons.heart_fill,
                            size: 32,
                            color: babyPink,
                          ));
                    },
                  ),
                  PullDownMenuItem(
                    title: 'Thumbs up',
                    icon: CupertinoIcons.hand_thumbsup_fill,
                    iconColor: blue,
                    onTap: () {
                      messageService.reactToMessage(
                          widget.conversationID, widget.messageID, '👍');
                      setState(() => emojiOverlay = const Text(
                            '👍',
                            style: TextStyle(fontSize: 28),
                          ));
                    },
                  ),
                ],
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onLongPress: showMenu,
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isCurrentUser
                              ? isOnlyEmoji(widget.message)
                                  ? [Colors.blue.shade50, Colors.blue.shade100]
                                  : [Colors.blue.shade300, Colors.blue]
                              : [
                                  CupertinoColors.tertiarySystemFill,
                                  CupertinoColors.secondarySystemFill
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft:
                              Radius.circular(widget.isCurrentUser ? 16 : 0),
                          bottomRight:
                              Radius.circular(widget.isCurrentUser ? 0 : 16),
                        ),
                      ),
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.6,
                          color: widget.isCurrentUser ? isOnlyEmoji(widget.message) ? CupertinoColors.black:
                               CupertinoColors.white
                              : CupertinoColors.label.resolveFrom(context),
                        ),
                      )),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(
                      left: widget.isCurrentUser ? 0 : 16,
                      right: widget.isCurrentUser ? 16 : 0,
                      top: 0,
                      bottom: 4),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context)),
                  )),
            ],
          ),
          if (emojiOverlay != null)
            Positioned(
              top: 0,
              left: widget.isCurrentUser ? 0 : null,
              right: widget.isCurrentUser ? null : 0,
              child: Container(
                child: emojiOverlay,
              ),
            ),
        ],
      ),
    );
  }

  void fetchAndSetReactions() async {
    final reactions = await MessageService()
        .getReactions(widget.conversationID, widget.messageID);
    if (reactions != null && reactions.isNotEmpty) {
      if (reactions.containsValue('❤️')) {
        setState(() {
          emojiOverlay =
              Icon(CupertinoIcons.heart_fill, size: 32, color: babyPink);
        });
      } else if (reactions.containsValue('👍')) {
        setState(() {
          emojiOverlay = const Text(
            '👍',
            style: TextStyle(fontSize: 28),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetReactions();
  }

  bool isOnlyEmoji(String text) {
    final emojiRegex = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    return emojiRegex.hasMatch(text);
  }
}
