import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class QuizState {
  final Map<String, List<Quiz>> quizzes;
  final bool hasLoaded;

  const QuizState({
    this.quizzes = const {},
    this.hasLoaded = false,
  });
}

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() {
    return const QuizState();
  }

  void addQuiz(String filePath, Quiz quiz) {
    state = QuizState(
      quizzes: {
        ...state.quizzes,
        filePath: [
          ...state.quizzes[filePath] ?? [],
          quiz,
        ],
      },
      hasLoaded: state.hasLoaded,
    );
  }

  List<Quiz> getQuizzes(String filePath) {
    return state.quizzes[filePath] ?? [];
  }

  Future<void> loadAllQuizzes() async {
    if (state.hasLoaded) {
      print("Quizzes already loaded into Riverpod");
      return;
    }

    final repository = DocumentRepository(
      ref.read(databaseProvider),
    );

    print("Loading all quizzes from SQLite");

    final savedQuizzes = await repository.getAllQuizzes();

    final loadedQuizzes = <String, List<Quiz>>{};

    for (final item in savedQuizzes) {
      final document = await repository.getDocumentById(
        item.documentId,
      );

      if (document == null) {
        continue;
      }

      loadedQuizzes.update(
        document.filePath,
        (existingQuizzes) => [
          ...existingQuizzes,
          item.quiz,
        ],
        ifAbsent: () => [item.quiz],
      );
    }

    state = QuizState(
      quizzes: loadedQuizzes,
      hasLoaded: true,
    );

    print("All quizzes loaded into Riverpod");
    print("Documents with quizzes: ${loadedQuizzes.length}");
  }
}

final quizProvider =
    NotifierProvider<QuizNotifier, QuizState>(
  QuizNotifier.new,
);