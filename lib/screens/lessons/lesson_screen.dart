import 'package:flutter/material.dart';
import '../home/widgets/lesson_option_card.dart';
import '../lessons/quizzes_screen.dart';
import '../lessons/note_screen.dart';
import '../lessons/video_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          LessonOptionCard(
            icon: Icons.note_outlined,
            color: Colors.blue,
            title: "Notes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteScreen()),
              );
            },
          ),
          LessonOptionCard(
            icon: Icons.video_library,
            color: Colors.red,
            title: "Videos",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VideoScreen()),
              );
            },
          ),
          LessonOptionCard(
            icon: Icons.quiz,
            color: Colors.green,
            title: "Quizzes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizzesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
