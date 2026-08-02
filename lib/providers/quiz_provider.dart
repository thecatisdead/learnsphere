import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';

class QuizNotifier extends Notifier<Map<String, Quiz>> {
  @override
  Map<String, Quiz> build() {
    return {};
  }

  void setQuiz(String filePath, Quiz quiz) {
    state = {...state, filePath: quiz};
  }

  Quiz? getQuiz(String filePath) {
    return state[filePath];
  }

  void clearQuiz(String filePath) {
    final newState = {...state};
    newState.remove(filePath);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

final quizProvider = NotifierProvider<QuizNotifier, Map<String, Quiz>>(
  QuizNotifier.new,
);
