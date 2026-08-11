import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/summary_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/flashcard_provider.dart';

import 'package:learnsphere/services/ai_service.dart';
import '../../models/quiz.dart';
import '../../models/summary.dart';
import '../providers/ai_material_provider.dart';

import '../providers/pdf_text_provider.dart';
import 'package:learnsphere/database/database_provider.dart';
import '../database/document_repository.dart';
import '../providers/document_provider.dart';

enum AiTask { none, summary, quiz, flashcards }

enum AiTaskStatus { idle, generating, ready, error }

class AiGenerationState {
  final String? filePath;

  final AiTaskStatus summaryStatus;
  final AiTaskStatus quizStatus;
  final AiTaskStatus flashcardStatus;

  const AiGenerationState({
    this.filePath,
    this.summaryStatus = AiTaskStatus.idle,
    this.quizStatus = AiTaskStatus.idle,
    this.flashcardStatus = AiTaskStatus.idle,
  });

  AiGenerationState copyWith({
    String? filePath,
    AiTaskStatus? summaryStatus,
    AiTaskStatus? quizStatus,
    AiTaskStatus? flashcardStatus,
  }) {
    return AiGenerationState(
      filePath: filePath ?? this.filePath,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      quizStatus: quizStatus ?? this.quizStatus,
      flashcardStatus: flashcardStatus ?? this.flashcardStatus,
    );
  }
}

class AiLoadingNotifier extends Notifier<AiGenerationState> {
  @override
  AiGenerationState build() {
    return const AiGenerationState();
  }

  void start(AiTask task, String filePath) {
    // If this is a different PDF, start fresh.
    if (state.filePath != filePath) {
      state = AiGenerationState(
        filePath: filePath,
        summaryStatus:
            task == AiTask.summary
                ? AiTaskStatus.generating
                : AiTaskStatus.idle,
        quizStatus:
            task == AiTask.quiz ? AiTaskStatus.generating : AiTaskStatus.idle,
        flashcardStatus:
            task == AiTask.flashcards
                ? AiTaskStatus.generating
                : AiTaskStatus.idle,
      );
      return;
    }

    // Same PDF: keep the other AI results.
    switch (task) {
      case AiTask.summary:
        state = state.copyWith(summaryStatus: AiTaskStatus.generating);
        break;

      case AiTask.quiz:
        state = state.copyWith(quizStatus: AiTaskStatus.generating);
        break;

      case AiTask.flashcards:
        state = state.copyWith(flashcardStatus: AiTaskStatus.generating);
        break;

      case AiTask.none:
        break;
    }
  }

  void finish(AiTask task) {
    switch (task) {
      case AiTask.summary:
        state = state.copyWith(summaryStatus: AiTaskStatus.ready);
        break;

      case AiTask.quiz:
        state = state.copyWith(quizStatus: AiTaskStatus.ready);
        break;

      case AiTask.flashcards:
        state = state.copyWith(flashcardStatus: AiTaskStatus.ready);
        break;

      case AiTask.none:
        break;
    }
  }

  void error(AiTask task) {
    switch (task) {
      case AiTask.summary:
        state = state.copyWith(summaryStatus: AiTaskStatus.error);
        break;

      case AiTask.quiz:
        state = state.copyWith(quizStatus: AiTaskStatus.error);
        break;

      case AiTask.flashcards:
        state = state.copyWith(flashcardStatus: AiTaskStatus.error);
        break;

      case AiTask.none:
        break;
    }
  }

  void reset() {
    state = const AiGenerationState();
  }

  Future<void> generateSummary({
    required String filePath,
    required String fileName,
    required String documentId,
  }) async {
    start(AiTask.summary, filePath);

    try {
      final text = await ref.read(pdfTextProvider.notifier).loadText(filePath);

      final summaryText = await AiService.generateSummary(text);

      print("✅ Summary generated");

      final summary = SummaryModel(fileName: fileName, text: summaryText);

      ref.read(summaryProvider.notifier).setSummary(filePath, summary);

      ref.read(aiMaterialProvider.notifier).setSummaryReady(filePath);

      final documentRepository = DocumentRepository(ref.read(databaseProvider));

      // Save the new summary as a NEW row.
      await documentRepository.saveSummary(
        documentId: documentId,
        summary: summaryText,
      );

      print("✅ saveSummary finished");

      // Only mark the document as generated after saving succeeds.
      await documentRepository.markSummaryGenerated(documentId);

      final savedSummaries = await documentRepository.getSummaries(documentId);

      print("📚 SUMMARY COUNT: ${savedSummaries.length}");

      for (final saved in savedSummaries) {
        print("📝 Summary ID: ${saved.id}");
        print("📄 Document ID: ${saved.documentId}");
        print("📄 Length: ${saved.summaryText.length}");
        print("🕒 Created: ${saved.createdAt}");
      }

      ref.invalidate(documentProvider(documentId));

      finish(AiTask.summary);
    } catch (e) {
      error(AiTask.summary);
      print(e.toString());
    }
  }

  Future generateQuiz({
    required String filePath,
    required String fileName,
    required String documentId,
  }) async {
    start(AiTask.quiz, filePath);

    try {
      final text = await ref.read(pdfTextProvider.notifier).loadText(filePath);

      final questions = await AiService.generateQuiz(text);

      final quiz = Quiz(fileName: fileName, questions: questions);

      ref.read(quizProvider.notifier).setQuiz(filePath, quiz);

      ref.read(aiMaterialProvider.notifier).setQuizReady(filePath);

      final documentRepository = DocumentRepository(ref.read(databaseProvider));

      print("💾 ABOUT TO SAVE QUIZ");

      await documentRepository.saveQuiz(documentId: documentId, quiz: quiz);

      print("✅ saveQuiz finished");

      await documentRepository.markQuizGenerated(documentId);

      ref.invalidate(documentProvider(documentId));

      finish(AiTask.quiz);
    } catch (e) {
      error(AiTask.quiz);
      print(e.toString());
    }
  }

  Future<void> generateFlashcards({
    required String filePath,
    required String fileName,
    required String documentId,
  }) async {
    start(AiTask.flashcards, filePath);

    try {
      final text = await ref.read(pdfTextProvider.notifier).loadText(filePath);

      final flashcards = await AiService.generateFlashcards(fileName, text);

      print("✅ Flashcards generated");
      print("📚 Card count: ${flashcards.flashcards.length}");

      final documentRepository = DocumentRepository(ref.read(databaseProvider));

      // Save flashcards permanently in SQLite.
      print("💾 ABOUT TO SAVE FLASHCARDS");

      await documentRepository.saveFlashcards(
        documentId: documentId,
        deck: flashcards,
      );

      print("saveFlashcards finished");

      // Keep the generated deck in Riverpod for immediate use.
      ref
          .read(flashcardProvider.notifier)
          .setFlashcardDeck(filePath, flashcards);

      print("⚡ Flashcards stored in Riverpod");

      // Tell the UI that flashcards are ready.
      ref.read(aiMaterialProvider.notifier).setFlashcardsReady(filePath);

      // Mark the document as having generated flashcards.
      await documentRepository.markFlashcardsGenerated(documentId);

      ref.invalidate(documentProvider(documentId));

      finish(AiTask.flashcards);

      print("FLASHCARD GENERATION FINISHED");
    } catch (e) {
      error(AiTask.flashcards);
      print("FLASHCARD ERROR: $e");
    }
  }
}

final aiLoadingProvider =
    NotifierProvider<AiLoadingNotifier, AiGenerationState>(
      AiLoadingNotifier.new,
    );
