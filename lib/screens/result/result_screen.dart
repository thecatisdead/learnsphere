import 'package:flutter/material.dart';
import '../quiz/quiz_screen.dart';
import '/models/question.dart';
import '/app/main_navigation.dart';
import '/../models/quiz.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String fileName;
  final List<Question> questions;
  final List<String> userAnswers;
  final String documentId;
  final String filePath;
  final Quiz quiz;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.fileName,
    required this.questions,
    required this.userAnswers,
    required this.documentId,
    required this.filePath,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;
    final progress = score / totalQuestions;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 36),

                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Your Score",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$score/$totalQuestions ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              "${percentage.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            minHeight: 6.0,
                            borderRadius: BorderRadius.circular(8),
                            color:
                                percentage >= 90
                                    ? Colors.green
                                    : percentage >= 80
                                    ? Colors.blue
                                    : percentage >= 70
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),

                        if (percentage >= 90)
                          const Text(
                            "🏆 Excellent!",
                            style: TextStyle(fontSize: 18),
                          )
                        else if (percentage >= 80)
                          const Text(
                            "👍 Great Job!",
                            style: TextStyle(fontSize: 18),
                          )
                        else if (percentage >= 70)
                          const Text(
                            "🙂 Good Job!",
                            style: TextStyle(fontSize: 18),
                          )
                        else
                          const Text(
                            "🔄 Keep Practicing!",
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ),

                for (int i = 0; i < questions.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question ${i + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          Text(
                            questions[i].question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ...questions[i].options.map((option) {
                            return Card(
                              color:
                                  option == questions[i].correctAnswer
                                      ? const Color.fromRGBO(240, 253, 244, 1.0)
                                      : option == userAnswers[i]
                                      ? const Color.fromRGBO(254, 242, 242, 1.0)
                                      : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color:
                                      option == questions[i].correctAnswer
                                          ? const Color.fromRGBO(
                                            34,
                                            197,
                                            94,
                                            1.0,
                                          )
                                          : option == userAnswers[i]
                                          ? const Color.fromRGBO(
                                            239,
                                            68,
                                            68,
                                            1.0,
                                          )
                                          : const Color.fromRGBO(
                                            189,
                                            231,
                                            235,
                                            1.0,
                                          ),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        option == questions[i].correctAnswer
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                userAnswers[i] == questions[i].correctAnswer
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    userAnswers[i] == questions[i].correctAnswer
                                        ? Colors.green
                                        : Colors.red,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                userAnswers[i] == questions[i].correctAnswer
                                    ? "Correct!"
                                    : "Incorrect!",
                                style: TextStyle(
                                  color:
                                      userAnswers[i] ==
                                              questions[i].correctAnswer
                                          ? Colors.green
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          if (userAnswers[i] != questions[i].correctAnswer) ...[
                            const SizedBox(height: 4),

                            const Center(
                              child: Text(
                                "The correct answer is:",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Center(
                              child: Text(
                                questions[i].correctAnswer,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuizScreen(
                                  documentId: documentId,
                                  filePath: filePath,
                                  fileName: fileName,
                                    quiz: quiz,

                                ),
                          ),
                        );
                      },
                      child: const Text("Try Again"),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Return Home"),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
