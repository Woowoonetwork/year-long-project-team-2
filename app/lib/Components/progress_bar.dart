import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Screens/donor_screen.dart' as dos;


class ProgressBar extends StatelessWidget {
  final double progress;
  final List<String> labels;
  final Color color;
  final bool isReserved;
  final dos.OrderState currentState;

  const ProgressBar({
    Key? key,
    required this.progress,
    required this.labels,
    required this.color,
    required this.isReserved,
    required this.currentState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.topCenter,
      child: Timeline.tileBuilder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(space: 6.0, thickness: 3.0),
          nodePosition: 0,
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemCount: labels.length,
          itemExtentBuilder: (_, __) {
            final double padding = 16.0;
            final double availableWidth =
                MediaQuery.of(context).size.width - padding * 2;
            return availableWidth / labels.length;
          },
          oppositeContentsBuilder: (context, index) {
            return Container();
          },
          contentsBuilder: (context, index) {
            //return _buildProgressPoint(labels[index], currentState);
            final bool isCurrentState = labels[index] ==
                _getStateText(currentState); // Check if label matches current state
            return Text(
              labels[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: isReserved 
                    ? isCurrentState
                        ? CupertinoDynamicColor.resolve(
                            CupertinoColors.label, context)
                        : CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel, context)
                    :
                        CupertinoDynamicColor.resolve(
                            CupertinoColors.secondaryLabel, context)
              ),
            );
          },
          indicatorBuilder: (_, index) {
            if (!isReserved){
              return OutlinedDotIndicator(
                borderWidth: 2.0,
                color: color,
              );
            }
            if (index < (progress * labels.length).toInt()) {
              return DotIndicator(
                color: color,
              );
            } else {
              return OutlinedDotIndicator(
                borderWidth: 2.0,
                color: color,
              );
            }
          },
          connectorBuilder: (_, index, type) {
            if (index < (progress * labels.length).toInt()) {
              return SolidLineConnector(
                color: color,
              );
            } else {
              return DashedLineConnector(
                color: color,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressPoint(String text, dos.OrderState state) {

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper function to get the text representation of the order state
  String _getStateText(dos.OrderState state) {
    switch (state) {
      case dos.OrderState.reserved:
        return "Reserved";
      case dos.OrderState.confirmed:
        return "Confirmed";
      case dos.OrderState.delivering:
        return "Delivering";
      case dos.OrderState.readyToPickUp:
        return "Ready to Pick Up";
    }
  }
}
