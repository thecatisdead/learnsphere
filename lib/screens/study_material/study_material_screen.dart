import 'package:flutter/material.dart';
import 'package:learnsphere/providers/study_session_provider.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/services/pdf_services.dart';
import 'package:learnsphere/services/ai_service.dart';

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
        aiState.status == AiTaskStatus.generating &&
        aiState.filePath == session?.filePath;
    final isSummaryReady =
        aiState.task == AiTask.summary &&
        aiState.status == AiTaskStatus.ready &&
        aiState.filePath == session?.filePath;

    final isQuizLoading =
        aiState.task == AiTask.quiz &&
        aiState.status == AiTaskStatus.generating &&
        aiState.filePath == session?.filePath;
    final isQuizReady =
        aiState.task == AiTask.quiz &&
        aiState.status == AiTaskStatus.ready &&
        aiState.filePath == session?.filePath;

    final isFlashcardLoading =
        aiState.task == AiTask.flashcards &&
        aiState.status == AiTaskStatus.generating &&
        aiState.filePath == session?.filePath;

    final isFlashcardReady =
        aiState.task == AiTask.flashcards &&
        aiState.status == AiTaskStatus.ready &&
        aiState.filePath == session?.filePath;

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
                      : () {
                        if (session == null) return;

                        if (isSummaryReady) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SummaryScreen(),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(aiLoadingProvider.notifier)
                            .generateSummary(
                              filePath: session.filePath,
                              fileName: session.fileName,
                            );
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
                  // Icon → Spinner while generating
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

                  // Text area
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isGeneratingSummary
                          ? const LoadingDots(
                            text: "Generating Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : isSummaryReady
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check),
                              SizedBox(width: 8),
                              Text("Summary Ready"),
                            ],
                          )
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
                  isBusy
                      ? null
                      : () {
                        if (session == null) return;

                        if (isQuizReady) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => QuizScreen(fileName: session.fileName),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(aiLoadingProvider.notifier)
                            .generateQuiz(
                              filePath: session.filePath,
                              fileName: session.fileName,
                            );
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
                        color: Color(0xFFF4C0D1),
                      ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isQuizLoading
                          ? const LoadingDots(
                            text: "Generating Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : isQuizReady
                          ? const Text(
                            "Quiz Ready",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : const Text(
                            "Generate Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          ),

                      const Text(
                        "AI-powered questions",
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
                  isBusy
                      ? null
                      : () {
                        if (session == null) return;

                        if (isFlashcardReady) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardScreen(),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(aiLoadingProvider.notifier)
                            .generateFlashcards(
                              filePath: session.filePath,
                              fileName: session.fileName,
                            );
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
                        color: Color.fromARGB(255, 4, 12, 83),
                      ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isFlashcardLoading
                          ? const LoadingDots(
                            text: "Generating Flashcards",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : isFlashcardReady
                          ? const Text(
                            "Flashcards Ready",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
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
