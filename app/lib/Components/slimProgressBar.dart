import 'package:flutter/material.dart';
import 'package:FoodHood/Components/colors.dart';

class SlimProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final List<String> stepTitles;

  SlimProgressBar({
    required this.currentIndex,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(totalSteps, (index) {
              return _buildStepIndicator(index);
            }),
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

  Widget _buildStepIndicator(int index) {
    bool isActive = index <= currentIndex;
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? accentColor : Colors.grey[300],
            border: Border.all(color: accentColor, width: 2),
          ),
        ),
        if (index != totalSteps - 1)
          SizedBox(
            width: 20,
            height: 2,
            child: Container(
              color: isActive ? accentColor : Colors.grey[300],
            ),
          ),
      ],
    );
  }
}
