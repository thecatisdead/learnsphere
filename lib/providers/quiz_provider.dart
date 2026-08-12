import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class QuizNotifier extends Notifier<Map<String, List<Quiz>>> {
  @override
  Map<String, List<Quiz>> build() {
    return {};
  }

  void addQuiz(String filePath, Quiz quiz) {
    state = {
      ...state,
      filePath: [
        ...state[filePath] ?? [],
        quiz,
      ],
    };
  }

  List<Quiz> getQuizzes(String filePath) {
    return state[filePath] ?? [];
  }

  Future<void> loadQuizzes({
    required String documentId,
    required String filePath,
    required String fileName,
  }) async {
    final repository =
        DocumentRepository(ref.read(databaseProvider));

    final savedQuizzes =
        await repository.getQuizzes(documentId);

    print("Loading quizzes from SQLite");
    print("SQLite quiz count: ${savedQuizzes.length}");

    if (savedQuizzes.isEmpty) {
      print("No quizzes found in SQLite");
      return;
    }

    state = {
      ...state,
      filePath: savedQuizzes,
    };

    print("Quizzes loaded into Riverpod");
    print("Riverpod quiz count: ${savedQuizzes.length}");
  }
}

final quizProvider = NotifierProvider<QuizNotifier, Map<String, List<Quiz>>>(
  QuizNotifier.new,
);
