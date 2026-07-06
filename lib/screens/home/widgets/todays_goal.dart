import 'package:flutter/material.dart';
import 'package:learnsphere/shared/widgets/app_card.dart';


class TodaysGoalCard extends StatelessWidget {
  const TodaysGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🎯 Today's Goal"),
          Text("Complete the Flutter Basics course."),
        ],
      ),
    );
  }
}