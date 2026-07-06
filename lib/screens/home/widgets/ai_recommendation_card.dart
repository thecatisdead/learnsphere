import 'package:flutter/material.dart';
import 'package:learnsphere/shared/widgets/app_card.dart';

class AIRecommendationCard extends StatelessWidget {
  const AIRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🤖 Study Coach,", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Review State Management Today."),
          SizedBox(height: 8),
          Text("Estimated Time: 30 minutes."),
          SizedBox(height: 8),

          Center(
            child: ElevatedButton(
              onPressed: () {},
              child: Text("Start Studying"),
            ),
          ),
        ],
      ),
    );
  }
}
