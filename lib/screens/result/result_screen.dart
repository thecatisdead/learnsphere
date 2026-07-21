import 'package:flutter/material.dart';
import '../quiz/quiz_screen.dart';
import '/../models/question.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String fileName;
  final List<Question> questions;
  final List<String> userAnswers;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.fileName,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("Your Score"),
            Text("$score / $totalQuestions"),

            for (int i = 0; i < questions.length; i++)
              Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Question ${i + 1}"),
                    Text(questions[i].question),
                    Text("Your Answer"),
                    Text(userAnswers[i]),
                    Text("Correct Answer"),
                    Text(questions[i].correctAnswer),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return QuizScreen(fileName: fileName);
                    },
                  ),
                );
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
