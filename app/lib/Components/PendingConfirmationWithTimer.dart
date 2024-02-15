import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PendingConfirmationWithTimer extends StatefulWidget {
  final int durationInSeconds;

  PendingConfirmationWithTimer({required this.durationInSeconds});

  @override
  _PendingConfirmationWithTimerState createState() =>
      _PendingConfirmationWithTimerState();
}

class _PendingConfirmationWithTimerState
    extends State<PendingConfirmationWithTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );

    PendingConfirmationWithTimer(durationInSeconds: 120);
    _controller.value = 0.02;

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_progress >= widget.durationInSeconds) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _progress += 1;
          });
        }
      },
    );
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
