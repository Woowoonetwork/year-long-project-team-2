import 'dart:async';
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
  Timer? _timer;

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
    });

    _controller.forward();
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
    }).catchError((error) {
      // Handle errors, perhaps log them or show a Snackbar
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Pending Confirmation',
            style: TextStyle(
              color: CupertinoColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _controller.value,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
