import 'package:flutter/material.dart';
import '../result/result_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quiz_provider.dart';


class QuizScreen extends ConsumerStatefulWidget {
  final String fileName;

  const QuizScreen({super.key, required this.fileName});

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
    final questions = ref.watch(quizProvider);
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
                // error here, fix later; When the user click next without choosing an answer it errors.
                userAnswers.add(selectedAnswer!);
                //
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
