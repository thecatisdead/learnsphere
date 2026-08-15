import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../result/result_screen.dart';
import '../../models/quiz.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String documentId;
  final String filePath;
  final String fileName;
  final Quiz quiz;

  const QuizScreen({
    super.key,
    required this.fileName,
    required this.documentId,
    required this.filePath,
    required this.quiz,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;

  List<String> userAnswers = [];

  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    // Use the exact quiz that was clicked.
    final quiz = widget.quiz;

    final questions = quiz.questions;

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("This quiz has no questions.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentQuestion + 1} of ${questions.length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              questions[currentQuestion].question,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                if (selectedAnswer == null) {
                  return;
                }

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
                      builder:
                          (context) => ResultScreen(
                            score: score,
                            totalQuestions: questions.length,
                            fileName: widget.fileName,
                            questions: quiz.questions,
                            userAnswers: userAnswers,
                            documentId: widget.documentId,
                            filePath: widget.filePath,
                            quiz: quiz,
                          ),
                    ),
                  );
                }
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
