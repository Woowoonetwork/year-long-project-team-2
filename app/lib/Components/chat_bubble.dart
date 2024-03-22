
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
            color: isCurrentUser
                ? accentColor.resolveFrom(context)
                : CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(100000.0)),
        child: Text(
          message,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6 ,
              color: isCurrentUser
                  ? CupertinoColors.white
                  : CupertinoColors.label.resolveFrom(context)),
        ),
      ),
    );
  }

 
}
