import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MessageInputRow extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;
  final firstName;
  final FocusNode? focusNode;
  final List<String> recommendedMessages = [
    "Sure, see you then!",
    "On my way",
    "Can we reschedule?",
    "Let me check my calendar",
    "Running late, sorry!",
  ];

  MessageInputRow({
    super.key,
    required this.firstName,
    required this.messageController,
    required this.sendMessage,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final inputFillColor =
        CupertinoColors.tertiarySystemFill.resolveFrom(context);
    final suggestionFillColor =
        CupertinoColors.tertiarySystemFill.resolveFrom(context);
    final placeholderTextColor =
        CupertinoColors.placeholderText.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickResponses(
              context, suggestionFillColor, labelColor),
          _buildMessageInput(context, inputFillColor, placeholderTextColor),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
      BuildContext context, Color fillColor, Color placeholderTextColor) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: messageController,
              prefix: PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Photos',
                    icon: CupertinoIcons.photo,
                    onTap: () {},
                  ),
                  PullDownMenuItem(
                    title: 'Camera',
                    icon: CupertinoIcons.camera,
                    onTap: () {},
                  ),
                ],
                
                buttonBuilder: (context, showMenu) => CupertinoButton(
                    onPressed: showMenu,
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100000),
                      ),
                      child: Icon(FeatherIcons.plus,
                          size: 18,
                          color:
                              CupertinoColors.systemGrey.resolveFrom(context)),
                    )),
              ),
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: sendMessage,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(100000),
                  ),
                  child: const Icon(FeatherIcons.arrowUp,
                      size: 20, color: Colors.white),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              
              focusNode: focusNode,
              placeholder: "Message $firstName",
              placeholderStyle: TextStyle(
                letterSpacing: -0.6,
                fontWeight: FontWeight.w500,
                color: placeholderTextColor,
              ),
              style: TextStyle(
                letterSpacing: -0.6,
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: CupertinoColors.label.resolveFrom(context),
              ),
              decoration: const BoxDecoration(),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResponses(
      BuildContext context, Color fillColor, Color labelColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedMessages.length,
        separatorBuilder: (context, index) => const SizedBox(
            width: 8), // Adjusts horizontal spacing between items
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => messageController.text = recommendedMessages[index],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  recommendedMessages[index],
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w500,
                      color: labelColor.withOpacity(0.8)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
