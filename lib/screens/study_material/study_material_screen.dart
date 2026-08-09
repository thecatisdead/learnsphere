import 'package:flutter/material.dart';
import 'package:learnsphere/providers/study_session_provider.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/screens/chat/study_chat_screen.dart';

import '../../providers/ai_loading_provider.dart';
import '../../providers/ai_material_provider.dart';
import '../../providers/chat_session_provider.dart';
import '../../database/database_provider.dart';

import '../../shared/widgets/loadingdots_widget.dart';
import '/../screens/quiz/quiz_screen.dart';
import '/../screens/flashcard/flashcard_screen.dart';
import '../../database/chat_repository.dart';

import '../../database/document_repository.dart';
import '../../providers/document_provider.dart';

class StudyMaterialScreen extends ConsumerWidget {
  const StudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(studySessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No PDF selected.")));
    }

    final aiState = ref.watch(aiLoadingProvider);

    final documentAsync = ref.watch(documentProvider(session.documentId));

    final document = documentAsync.value;

    final isSummaryReady = document?.summaryGenerated ?? false;

    final isQuizReady = document?.quizGenerated ?? false;

    final isFlashcardReady = document?.flashcardsGenerated ?? false;

    final isGeneratingSummary =
        aiState.summaryStatus == AiTaskStatus.generating &&
        aiState.filePath == session.filePath;

    final isQuizLoading =
        aiState.quizStatus == AiTaskStatus.generating &&
        aiState.filePath == session.filePath;

    final isFlashcardLoading =
        aiState.flashcardStatus == AiTaskStatus.generating &&
        aiState.filePath == session.filePath;

    final isBusy =
        aiState.summaryStatus == AiTaskStatus.generating ||
        aiState.quizStatus == AiTaskStatus.generating ||
        aiState.flashcardStatus == AiTaskStatus.generating;

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
                title: Text(
                  session?.fileName ?? "No PDF Selected",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
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
                              builder:
                                  (_) => SummaryScreen(
                                    documentId: session.documentId,
                                    filePath: session.filePath,
                                    fileName: session.fileName,
                                  ),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(aiLoadingProvider.notifier)
                            .generateSummary(
                              filePath: session.filePath,
                              fileName: session.fileName,
                              documentId: session.documentId,
                            );
                      },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                elevation: 2, // Shadow
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

                      Text(
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
                                  (_) => QuizScreen(
                                    documentId: session.documentId,
                                    filePath: session.filePath,
                                    fileName: session.fileName,
                                  ),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(aiLoadingProvider.notifier)
                            .generateQuiz(
                              filePath: session.filePath,
                              fileName: session.fileName,
                              documentId: session.documentId,
                            );
                      },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                elevation: 2, // Shadow
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
                          ? const LoadingDots(
                            text: "Generating Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : isQuizReady
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check),
                              SizedBox(width: 8),
                              Text("Quiz Ready"),
                            ],
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
                              documentId: session.documentId,
                            );
                      },
              style: ElevatedButton.styleFrom(
                elevation: 2, // Shadow
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
                          ? const LoadingDots(
                            text: "Generating Flashcards",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C2C2A),
                            ),
                          )
                          : isFlashcardReady
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                color: Color.fromARGB(255, 5, 5, 5),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Flashcards Ready",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 5, 5, 5),
                                ),
                              ),
                            ],
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
            ElevatedButton(
              onPressed: () async {
                final repository = ChatRepository(ref.read(databaseProvider));
                final latestChat = await repository.getLatestChatForDocument(
                  session.documentId,
                );
                String chatId;
                if (latestChat == null) {
                  chatId = await ref
                      .read(chatSessionsProvider.notifier)
                      .createChat(documentId: session.documentId);
                } else {
                  chatId = latestChat.id;
                  await ref
                      .read(chatSessionsProvider.notifier)
                      .loadChat(chatId);
                }
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StudyChatScreen(
                          fileName: session.fileName,
                          filePath: session.filePath,
                          chatId: chatId,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 2, // Shadow
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Ask AI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C2C2A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
