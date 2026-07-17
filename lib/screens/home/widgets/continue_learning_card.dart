import 'package:flutter/material.dart';
import 'package:learnsphere/shared/widgets/app_card.dart';
import '../../lessons/lesson_screen.dart';

class ContinueLearningCard extends StatelessWidget {
  final double progress;

  const ContinueLearningCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LessonScreen()),
          );
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📚 Continue Learning",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Text("Flutter Fundamentals"),

            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: const Color.fromARGB(181, 0, 110, 255),
              minHeight: 12.0,
              borderRadius: BorderRadius.circular(8),
            ),

            SizedBox(height: 8),
            Text("${(progress * 100).toInt()}% Complete"),
          ],
        ),
      ),
    );
  }
}
