import 'package:flutter/material.dart';
import 'package:learnsphere/providers/study_session_provider.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/services/pdf_services.dart';
import 'package:learnsphere/services/ai_service.dart';
import '../../models/summary.dart';
import '../../models/ai_generation_state.dart';

import '../../providers/summary_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/ai_loading_provider.dart';

import '../../shared/widgets/loadingdots_widget.dart';
import '/../screens/quiz/quiz_screen.dart';
import '/../screens/flashcard/flashcard_screen.dart';

class StudyMaterialScreen extends ConsumerWidget {
  const StudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(studySessionProvider);

    final aiState = ref.watch(aiLoadingProvider);

    final isGeneratingSummary =
        aiState.task == AiTask.summary &&
        aiState.status == AiTaskStatus.generating;

    final isSummaryReady =
        aiState.task == AiTask.summary && aiState.status == AiTaskStatus.ready;

    final isQuizLoading =
        aiState.task == AiTask.questions &&
        aiState.status == AiTaskStatus.generating;

    final isQuizReady =
        aiState.task == AiTask.questions &&
        aiState.status == AiTaskStatus.ready;

    final isFlashcardLoading =
        aiState.task == AiTask.flashcards &&
        aiState.status == AiTaskStatus.generating;

    final isFlashcardReady =
        aiState.task == AiTask.flashcards &&
        aiState.status == AiTaskStatus.ready;

    final isBusy = aiState.status == AiTaskStatus.generating;

    return Scaffold(
      appBar: AppBar(title: const Text("Study Material")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFFF5C4B3),
                ),
                title: Text(session?.fileName ?? "No PDF Selected"),
                subtitle: const Text("Ready to study"),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "CHOOSE AN AI TOOL",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed:
                  isBusy
                      ? null
                      : () async {
                        if (session == null) return;

                        ref
                            .read(aiLoadingProvider.notifier)
                            .start(AiTask.summary);

                        try {
                          final text = await PdfService.extractText(
                            session.filePath,
                          );

                          final summaryText = await AiService.generateSummary(
                            text,
                          );

                          if (!context.mounted) return;

                          final summary = Summary(
                            fileName: session.fileName,
                            text: summaryText,
                          );

                          ref
                              .read(summaryProvider.notifier)
                              .setSummary(summary);

                          ref.read(aiLoadingProvider.notifier).finish();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SummaryScreen(),
                            ),
                          );
                        } catch (e) {
                          ref.read(aiLoadingProvider.notifier).error();

                          debugPrint(e.toString());
                        } finally {
                          if (context.mounted) {}
                        }
                      },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                elevation: 5, // Shadow
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: Row(
                children: [
                  isGeneratingSummary
                      ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFFCECBF6),
                        ),
                      )
                      : const Icon(
                        Icons.summarize,
                        size: 28,
                        color: Color(0xFFCECBF6),
                      ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isGeneratingSummary
                          ? const LoadingDots(text: "Generating Summary")
                          : isSummaryReady
                          ? const Text("✓ Ready")
                          : const Text(
                            "Generate Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),

                      const Text(
                        "AI-powered notes",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F5E5A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed:
                  isQuizLoading
                      ? null
                      : () async {
                        if (session == null) return;

                        ref
                            .read(aiLoadingProvider.notifier)
                            .start(AiTask.questions);

                        try {
                          final text = await PdfService.extractText(
                            session.filePath,
                          );

                          final questions = await AiService.generateQuiz(text);

                          ref.read(quizProvider.notifier).setQuiz(questions);

                          print("Questions generated: ${questions.length}");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => QuizScreen(fileName: session.fileName),
                            ),
                          );
                        } finally {
                          ref.read(aiLoadingProvider.notifier).finish();
                        }
                      },

              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                elevation: 5, // Shadow
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: Row(
                children: [
                  isQuizLoading
                      ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFFCECBF6),
                        ),
                      )
                      : const Icon(
                        Icons.quiz,
                        size: 28,
                        color: Color(0xFF9FE1CB),
                      ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isQuizLoading
                          ? const LoadingDots(text: "Generating Quiz")
                          : const Text(
                            "Generate Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),

                      const Text(
                        "AI-powered quizzes",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F5E5A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed:
                  isFlashcardLoading
                      ? null
                      : () async {
                        if (session == null) return;

                        ref
                            .read(aiLoadingProvider.notifier)
                            .start(AiTask.flashcards);

                        try {
                          final text = await PdfService.extractText(
                            session.filePath,
                          );

                          final deck = await AiService.generateFlashcards(
                            session.fileName,
                            text,
                          );

                          ref
                              .read(flashcardProvider.notifier)
                              .setFlashcardDeck(deck);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FlashcardScreen(),
                            ),
                          );
                        } finally {
                          ref.read(aiLoadingProvider.notifier).finish();
                        }
                      },

              style: ElevatedButton.styleFrom(
                elevation: 5, // Shadow
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  isFlashcardLoading
                      ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFFCECBF6),
                        ),
                      )
                      : const Icon(
                        Icons.style,
                        size: 28,
                        color: Color(0xFFF4C0D1),
                      ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isFlashcardLoading
                          ? const LoadingDots(text: "Generating Flashcards")
                          : const Text(
                            "Generate Flashcards",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),

                      const Text(
                        "AI-powered flashcards",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F5E5A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
