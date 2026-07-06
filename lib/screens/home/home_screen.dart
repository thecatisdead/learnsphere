import 'package:flutter/material.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/trending_section.dart';

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          GreetingHeader(),
          SizedBox(height: 20),

          ContinueLearningCard(progress: 0.5),
          AIRecommendationCard(),
          TrendingSection(),
        ],
      ),
    );
  }
}
