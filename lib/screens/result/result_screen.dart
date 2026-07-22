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
    final percentage = (score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Result Screen")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  "Your Score",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                if (percentage >= 90)
                  Text("Excellent!")
                else if (percentage >= 80)
                  Text("Great Job!")
                else if (percentage >= 70)
                  Text("Good Job!")
                else
                  Text("Keep Practicing!"),

                Text(
                  "$score / $totalQuestions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),

                for (int i = 0; i < questions.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
        ),
      ),
    );
  }
}
