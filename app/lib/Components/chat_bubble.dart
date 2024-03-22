import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/cupertino.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isCurrentUser
                ? blue.resolveFrom(context)
                : CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(isCurrentUser ? 16 : 0),
              bottomRight: Radius.circular(isCurrentUser ? 0 : 16),
            )),
        child: Text(
          message,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: isCurrentUser
                  ? CupertinoColors.white
                  : CupertinoColors.label.resolveFrom(context)),
        ),
      ),
    );
  }
}
