import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoSnackbar extends StatelessWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Icon trailingIcon;

  const CupertinoSnackbar({
    Key? key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.backgroundColor = CupertinoColors.tertiarySystemBackground,
    required this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCupertinoSnackbar(
      message: message,
      duration: duration,
      backgroundColor: backgroundColor,
      trailingIcon: trailingIcon,
    );
  }
}

class AnimatedCupertinoSnackbar extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Icon trailingIcon;

  const AnimatedCupertinoSnackbar({
    Key? key,
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.trailingIcon,
  }) : super(key: key);

  @override
  _AnimatedCupertinoSnackbarState createState() =>
      _AnimatedCupertinoSnackbarState();
}

class _AnimatedCupertinoSnackbarState extends State<AnimatedCupertinoSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized
      ),
    );

    _controller.forward();

    // Schedule the reverse animation
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: CupertinoSnackbarContent(
        message: widget.message,
        backgroundColor: widget.backgroundColor,
        trailingIcon: widget.trailingIcon,
      ),
    );
  }
}

class CupertinoSnackbarContent extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Icon trailingIcon;

  const CupertinoSnackbarContent({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.8,
                  color: backgroundColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            trailingIcon.color == null
                ? trailingIcon
                : Icon(
                    trailingIcon.icon,
                    color: backgroundColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
          ],
        ),
      ),
    );
  }
}
