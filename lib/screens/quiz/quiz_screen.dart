import 'package:flutter/material.dart';
import '/../models/question.dart';

class QuizScreen extends StatefulWidget {
  final String fileName;

  const QuizScreen({super.key, required this.fileName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         

            const SizedBox(height: 24),

            const Text("Question 1 of 5", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            const Text(
              "Which language is used to build Flutter apps?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            RadioListTile(
              value: "Java",
              groupValue: null,
              onChanged: (_) {},
              title: const Text("Java"),
            ),

            RadioListTile(
              value: "Dart",
              groupValue: null,
              onChanged: (_) {},
              title: const Text("Dart"),
            ),

            RadioListTile(
              value: "Python",
              groupValue: null,
              onChanged: (_) {},
              title: const Text("Python"),
            ),

            RadioListTile(
              value: "C#",
              groupValue: null,
              onChanged: (_) {},
              title: const Text("C#"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
