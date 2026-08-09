import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';

import '../database/document_repository.dart';
import '../database/database_provider.dart';

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

  Future<void> loadQuiz({
    required String documentId,
    required String filePath,
    required String fileName,
  }) async {
    final repository = DocumentRepository(ref.read(databaseProvider));

    final savedQuiz = await repository.getQuiz(documentId);

    print("🧠 SQLite quiz query finished");

    if (savedQuiz == null) {
      print("❌ No quiz found in SQLite");
      return;
    }

    print("✅ Quiz found in SQLite");

    setQuiz(filePath, savedQuiz);
  }
}

final quizProvider = NotifierProvider<QuizNotifier, Map<String, Quiz>>(
  QuizNotifier.new,
);
