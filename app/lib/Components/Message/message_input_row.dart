import 'package:FoodHood/Components/colors.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputRow extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;
  final firstName;
  final FocusNode? focusNode;

  MessageInputRow({
    super.key,
    required this.firstName,
    required this.messageController,
    required this.sendMessage,
    this.focusNode,
  });

  @override
  _MessageInputRowState createState() => _MessageInputRowState();
}

class _MessageInputRowState extends State<MessageInputRow> {
  final List<String> recommendedMessages = [
    "Sure, see you then!",
    "On my way",
    "Can we reschedule?",
    "Let me check my calendar",
    "Running late, sorry!",
  ];
  bool _isSendButtonVisible = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_updateSendButtonVisibility);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_updateSendButtonVisibility);
    super.dispose();
  }

  void _updateSendButtonVisibility() {
    final isTextPresent = widget.messageController.text.isNotEmpty;
    setState(() {
      _isSendButtonVisible = isTextPresent;
    });
  }

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
          _buildQuickResponses(context, suggestionFillColor, labelColor),
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
        border: Border.all(
          color: CupertinoColors.systemGrey4.resolveFrom(context),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: widget.messageController,
              prefix: PullDownButton(
                itemBuilder: (context) => [
                  const PullDownMenuTitle(title: Text('Share Post from:')),
                  PullDownMenuItem(
                    title: 'Reserved Posts',
                    icon: CupertinoIcons.square_stack,
                    onTap: () {
                      _showReservedPostsSheet(context);
                    },
                  ),
                  const PullDownMenuDivider.large(),
                  const PullDownMenuTitle(title: Text('Send Image from:')),
                  PullDownMenuItem(
                    title: 'Photos',
                    icon: CupertinoIcons.photo,
                    onTap: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        print("Picked image path: ${image.path}");
                      }
                    },
                  ),
                  PullDownMenuItem(
                    title: 'Camera',
                    icon: CupertinoIcons.camera,
                    onTap: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        print("Captured image path: ${image.path}");
                      }
                    },
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
              suffix: _isSendButtonVisible
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.sendMessage,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: blue.resolveFrom(context),
                          borderRadius: BorderRadius.circular(100000),
                        ),
                        child: const Icon(FeatherIcons.arrowUp,
                            size: 20, color: Colors.white),
                      ))
                  : null,
              textCapitalization: TextCapitalization.sentences,
              focusNode: widget.focusNode,
              placeholder: "Message ${widget.firstName}",
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        ],
      ),
    );
  }

  void _showReservedPostsSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: DraggableScrollableSheet(
            initialChildSize: 0.5, // Half the height of its parent
            maxChildSize: 1, // Full height
            minChildSize: 0.25, // Quarter height
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white, // Background color for the bottom sheet
                child: Column(
                  children: [
                    _buildDragHandle(),
                    _buildCustomNavigationBar(context),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomNavigationBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reserved',
              style: TextStyle(
                  fontSize: 28,
                  letterSpacing: -1.3,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(FeatherIcons.x,
                  size: 24,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context))),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
            onTap: () =>
                widget.messageController.text = recommendedMessages[index],
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
