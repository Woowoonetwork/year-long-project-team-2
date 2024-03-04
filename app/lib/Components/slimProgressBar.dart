import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';

class SlimProgressBar extends StatelessWidget {
  final List<String> stepTitles;
  final String postStatus;

  SlimProgressBar({required this.stepTitles, required this.postStatus});

  @override
  Widget build(BuildContext context) {
    int currentIndex = _getCurrentIndex();
    int totalSteps = stepTitles.length;

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Container(
              width: double.infinity,
              child: Stack(
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
                      children: List.generate(totalSteps, (index) {
                        return _buildStepIndicator(index, currentIndex);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              return Text(
                stepTitles[index],
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

  Widget _buildStepIndicator(int index, int currentIndex) {
    bool isActive = index <= currentIndex;
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
    switch (postStatus) {
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
}
