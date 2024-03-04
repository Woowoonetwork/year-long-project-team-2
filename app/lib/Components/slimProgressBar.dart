import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';

class SlimProgressBar extends StatefulWidget {
  final List<String> stepTitles;
  final String postStatus;

  SlimProgressBar({required this.stepTitles, required this.postStatus});

  @override
  _SlimProgressBarState createState() => _SlimProgressBarState();
}

class _SlimProgressBarState extends State<SlimProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getCurrentIndex();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: _currentIndex.toDouble())
        .animate(_animationController);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant SlimProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    int newIndex = _getCurrentIndex();
    if (_currentIndex != newIndex) {
      _currentIndex = newIndex;
      _animation =
          Tween<double>(begin: _animation.value, end: _currentIndex.toDouble())
              .animate(_animationController);
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Container(
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Color.fromARGB(255, 133, 210, 175),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              List.generate(widget.stepTitles.length, (index) {
                            return _buildStepIndicator(
                                index, _animation.value.toInt());
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.stepTitles.length, (index) {
              return Text(
                widget.stepTitles[index],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index, int animatedIndex) {
    bool isActive = index <= animatedIndex;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? accentColor : Colors.white,
        border: Border.all(color: accentColor, width: 2),
      ),
    );
  }

  int _getCurrentIndex() {
    switch (widget.postStatus) {
      case 'confirmed':
        return 0;
      case 'out_for_delivery':
        return 1;
      case 'ready_for_pickup':
        return 2;
      case 'complete':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
