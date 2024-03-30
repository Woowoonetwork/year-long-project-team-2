import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoodHood/Components/colors.dart';

class PendingConfirmationWithTimer extends StatefulWidget {
  final int durationInSeconds;
  final String postId;

  const PendingConfirmationWithTimer({
    Key? key,
    required this.durationInSeconds,
    required this.postId,
  }) : super(key: key);

  @override
  _PendingConfirmationWithTimerState createState() =>
      _PendingConfirmationWithTimerState();
}

class _PendingConfirmationWithTimerState
    extends State<PendingConfirmationWithTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String _printDuration(Duration duration) {
    int totalSeconds = widget.durationInSeconds - duration.inSeconds;
    return "$totalSeconds s left";
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    )
      ..addListener(() {
        setState(() {});
        if (_controller.isCompleted) {
          _updatePostStatusAndPop();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(16, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 0),
            spreadRadius: 2,
          )
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Do nothing
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Stack(
            children: <Widget>[
              LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: CupertinoColors.tertiarySystemBackground
                      .resolveFrom(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      secondaryColor.resolveFrom(context)),
                  minHeight: 60),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Pending Confirmation',
                        style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 18,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _printDuration(Duration(
                            seconds:
                                (widget.durationInSeconds * _controller.value)
                                    .round())),
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePostStatusAndPop() async {
    await FirebaseFirestore.instance
        .collection('post_details')
        .doc(widget.postId)
        .update({
      'post_status': 'not reserved',
      'reserved_by': FieldValue.delete(),
    }).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }).catchError((error) {});
  }
}
