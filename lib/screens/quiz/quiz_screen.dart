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
  final List<Question> questions = [
    const Question(
      question: "What is the capital of France?",
      options: ["Berlin", "Madrid", "Paris", "Rome"],
      correctAnswer: "Paris",
    ),
    const Question(
      question: "What is 2 + 2?",
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
          children: [Text(questions[currentQuestion].question)
          , SizedBox(height: 10),
          ...questions[currentQuestion].options.map((option){return Text(option);})],
        ),
      ),
    );
  }
}
