import 'package:flutter/material.dart';
import '../home/widgets/lesson_option_card.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          LessonOptionCard(
            icon: Icons.note,
            title: "Notes",
            onTap: () {
              print("Notes tapped");
            },
          ),
          LessonOptionCard(
            icon: Icons.video_library,
            title: "Videos",
            onTap: () {
              print("Videos tapped");
            },
          ),
          LessonOptionCard(
            icon: Icons.quiz,
            title: "Quizzes",
            onTap: () {
              print("Quizzes tapped");
            },
          ),
        ],
      ),
    );
  }
}
