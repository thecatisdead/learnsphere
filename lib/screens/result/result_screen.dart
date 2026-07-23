import 'package:flutter/material.dart';
import '../quiz/quiz_screen.dart';
import '/../models/question.dart';
import '/app/main_navigation.dart';

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
    final progress = score / totalQuestions;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                SizedBox(height: 36),

                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize
                              .min, // Prevents the column from taking full screen height
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
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
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 30,
                              ),
                            ),

                            Text(
                              "${percentage.toStringAsFixed(0)}%",
                              style: TextStyle(
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
                          ), // Adjust values as needed

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
                          Text("🏆Excellent!", style: TextStyle(fontSize: 18))
                        else if (percentage >= 80)
                          Text("👍Great Job!", style: TextStyle(fontSize: 18))
                        else if (percentage >= 70)
                          Text("🙂Good Job!", style: TextStyle(fontSize: 18))
                        else
                          Text(
                            "🔄Keep Practicing!",
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
                        mainAxisAlignment:
                            MainAxisAlignment
                                .start, // Controls vertical alignment
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Question ${i + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            questions[i].question,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 8),
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
                                          : Color.fromRGBO(189, 231, 235, 1.0),

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
                          SizedBox(height: 16),

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
                              if (userAnswers[i] !=
                                  questions[i].correctAnswer) ...[
                                const SizedBox(width: 4),
                                const Text(
                                  "The correct answer is",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          if (userAnswers[i] != questions[i].correctAnswer)
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  questions[i].correctAnswer,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 8),
                        ],
                      ),
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
                      child: const Text("Try Again", style: TextStyle()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const MainNavigation();
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
