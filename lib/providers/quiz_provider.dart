import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';

final quizProvider = NotifierProvider<QuizNotifier, List<Question>>(
  QuizNotifier.new,
);

class QuizNotifier extends Notifier<List<Question>> {
  @override
  List<Question> build() {
    return [];
  }

  void setQuiz(List<Question> questions) {
    state = questions;
  }

  void clearQuiz() {
    state = [];
  }
}
