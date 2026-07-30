import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/summary_provider.dart';
import 'package:learnsphere/services/pdf_services.dart';
import 'package:learnsphere/services/ai_service.dart';
import '../../models/summary.dart';
import '../providers/quiz_provider.dart';
import '../providers/flashcard_provider.dart';

enum AiTask { none, summary, quiz, flashcards }

enum AiTaskStatus { idle, generating, ready, error }

class AiGenerationState {
  final AiTask task;
  final AiTaskStatus status;
  final String? filePath;

  const AiGenerationState({
    required this.task,
    required this.status,
    this.filePath,
  });

  AiGenerationState copyWith({
    AiTask? task,
    AiTaskStatus? status,
    String? filePath,
  }) {
    return AiGenerationState(
      task: task ?? this.task,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
    );
  }
}

class AiLoadingNotifier extends Notifier<AiGenerationState> {
  @override
  AiGenerationState build() {
    return const AiGenerationState(
      task: AiTask.none,
      status: AiTaskStatus.idle,
    );
  }

  void start(AiTask task, String filePath) {
    state = AiGenerationState(
      task: task,
      status: AiTaskStatus.generating,
      filePath: filePath,
    );
  }

  void finish() {
    state = AiGenerationState(
      task: state.task,
      status: AiTaskStatus.ready,
      filePath: state.filePath,
    );
  }

  void error() {
    state = AiGenerationState(
      task: state.task,
      status: AiTaskStatus.error,
      filePath: state.filePath,
    );
  }

  void reset() {
    state = const AiGenerationState(
      task: AiTask.none,
      status: AiTaskStatus.idle,
    );
  }

  Future<void> generateSummary({
    required String filePath,
    required String fileName,
  }) async {
    start(AiTask.summary, filePath);

    try {
      final text = await PdfService.extractText(filePath);

      final summaryText = await AiService.generateSummary(text);

      final summary = Summary(fileName: fileName, text: summaryText);

      ref.read(summaryProvider.notifier).setSummary(summary);

      finish();
    } catch (e) {
      error();
      print(e.toString());
    }
  }

  Future<void> generateQuiz({
    required String filePath,
    required String fileName,
  }) async {
    start(AiTask.quiz, filePath);

    try {
      final text = await PdfService.extractText(filePath);

      final quiz = await AiService.generateQuiz(text);

      ref.read(quizProvider.notifier).setQuiz(quiz);

      finish();
    } catch (e) {
      error();
      print(e.toString());
    }
  }

  Future<void> generateFlashcards({
    required String filePath,
    required String fileName,
  }) async {
    start(AiTask.flashcards, filePath);

    try {
      final text = await PdfService.extractText(filePath);

      final flashcards = await AiService.generateFlashcards(fileName, text);

      ref.read(flashcardProvider.notifier).setFlashcardDeck(flashcards);

      finish();
    } catch (e) {
      error();
      print(e.toString());
    }
  }
}

final aiLoadingProvider =
    NotifierProvider<AiLoadingNotifier, AiGenerationState>(
      AiLoadingNotifier.new,
    );
