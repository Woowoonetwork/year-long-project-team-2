import 'dart:async';
import 'package:FoodHood/Components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingConfirmationWithTimer extends StatefulWidget {
  final int durationInSeconds;
  final String postId;

  PendingConfirmationWithTimer({
    required this.durationInSeconds,
    required this.postId,
  });

  @override
  _PendingConfirmationWithTimerState createState() =>
      _PendingConfirmationWithTimerState();
}

class _PendingConfirmationWithTimerState
    extends State<PendingConfirmationWithTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(1, '0');
    int totalSeconds = widget.durationInSeconds - duration.inSeconds;
    String twoDigitMinutes = twoDigits(totalSeconds ~/ 60);
    String twoDigitSeconds = twoDigits(totalSeconds % 60);

    String formattedTimeLeft = "";
    if (totalSeconds ~/ 60 > 0) {
      formattedTimeLeft += "$twoDigitMinutes mins ";
    }
    if (totalSeconds % 60 > 0 || totalSeconds ~/ 60 == 0) {
      formattedTimeLeft += "$twoDigitSeconds secs";
    }

    formattedTimeLeft += " left";

    return formattedTimeLeft;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _updatePostStatusAndPop();
      }
      setState(() {});
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(
        seconds: (widget.durationInSeconds * _controller.value).round());
    String formattedTimeLeft = _printDuration(duration);

    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: LinearProgressIndicator(
              value: _controller.value,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.5)),
              minHeight: 40,
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 52),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Confirmation',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedTimeLeft,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
