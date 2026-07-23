import 'package:flutter/material.dart';
import '/../models/question.dart';
import '../result/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String fileName;

  const QuizScreen({super.key, required this.fileName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;

  List<String> userAnswers = [];

  String? selectedAnswer;
  final List<Question> questions = [
    const Question(
      question: "What is the capital of France?",
      options: ["Berlin", "Madrid", "Paris", "Rome"],
      correctAnswer: "Madrid",
    ),
    const Question(
      question: "What is 2 + 2?",
      options: ["3", "Madrid", "5", "6"],
      correctAnswer: "Madridasd asdasdasdas asd a  asd asd",
    ),
    const Question(
      question: "What is 2 + 3?",
      options: ["3", "4", "5", "6"],
      correctAnswer: "4",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(questions[currentQuestion].question),
            SizedBox(height: 10),
            ...questions[currentQuestion].options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    selectedAnswer = value;
                  });
                },
              );
            }),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                userAnswers.add(selectedAnswer!);

                if (selectedAnswer ==
                    questions[currentQuestion].correctAnswer) {
                  score++;
                }

                if (currentQuestion < questions.length - 1) {
                  setState(() {
                    currentQuestion++;

                    selectedAnswer = null;
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ResultScreen(
                          score: score,
                          totalQuestions: questions.length,
                          fileName: widget.fileName,
                          questions: questions,
                          userAnswers: userAnswers,
                        );
                      },
                    ),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
