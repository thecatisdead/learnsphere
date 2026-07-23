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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                SizedBox(height: 36),

                Text(
                  "Your Score",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$score/$totalQuestions • ",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "${percentage.toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                if (percentage >= 90)
                  Text("🏆Excellent!", style: TextStyle(fontSize: 22))
                else if (percentage >= 80)
                  Text("👍Great Job!", style: TextStyle(fontSize: 22))
                else if (percentage >= 70)
                  Text("🙂Good Job!", style: TextStyle(fontSize: 22))
                else
                  Text("🔄Keep Practicing!", style: TextStyle(fontSize: 22)),

                for (int i = 0; i < questions.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                          : Color.fromRGBO(229, 231, 235, 1.0),

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

                                  fontWeight: FontWeight.bold, fontSize: 16,
                                ),
                              ),
                              if (userAnswers[i] != questions[i].correctAnswer)
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                    children: [
                                      const TextSpan(
                                        text: " The correct answer is ",
                                      ),
                                      TextSpan(
                                        text: questions[i].correctAnswer,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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
