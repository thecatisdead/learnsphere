import 'package:flutter/material.dart';
import '../quiz/quiz_screen.dart';
import '/../models/question.dart';
import '/screens/home/home_screen.dart';

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
                    Text(
                      "Question ${i + 1}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(questions[i].question),

                    SizedBox(height: 8),
                    Text("Your Answer"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userAnswers[i],
                          style: TextStyle(
                            color:
                                userAnswers[i] == questions[i].correctAnswer
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),

                        Icon(
                          userAnswers[i] == questions[i].correctAnswer
                              ? Icons.check_circle
                              : Icons.cancel,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Text("Correct Answer"),
                    Text(questions[i].correctAnswer),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const HomeScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("Return Home"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
