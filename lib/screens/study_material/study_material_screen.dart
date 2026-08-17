import 'package:flutter/material.dart';
import 'package:learnsphere/providers/study_session_provider.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/screens/chat/study_chat_screen.dart';

import '../../providers/ai_loading_provider.dart';
import '../../providers/chat_session_provider.dart';
import '../../database/database_provider.dart';

import '../../shared/widgets/loadingdots_widget.dart';
import '/../screens/quiz/quiz_screen.dart';
import '../../database/chat_repository.dart';

import '../../providers/document_provider.dart';

import '../../providers/summary_provider.dart';

import '../../providers/quiz_provider.dart';

import '../../providers/flashcard_provider.dart';

import '../flashcard/flashcard_screen.dart';

class StudyMaterialScreen extends ConsumerStatefulWidget {
  const StudyMaterialScreen({super.key});

  @override
  ConsumerState<StudyMaterialScreen> createState() =>
      _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends ConsumerState<StudyMaterialScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadStudyMaterialsFromSqlite();
    });
  }

  Future<void> _loadStudyMaterialsFromSqlite() async {
    final session = ref.read(studySessionProvider);

    if (session == null) {
      return;
    }

    print("Loading study materials from SQLite...");
    print("Document ID: ${session.documentId}");

    await ref.read(summaryProvider.notifier).loadAllSummaries();

    await ref.read(quizProvider.notifier).loadAllQuizzes();

    await ref.read(flashcardProvider.notifier).loadAllFlashcards();
    print("Study materials loaded into Riverpod");
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiGenerationState>(aiLoadingProvider, (previous, next) {
      if (next.errorMessage != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Generation Failed"),
                ],
              ),
              content: Text(next.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ref.read(aiLoadingProvider.notifier).clearError();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });

    // KEEP THIS
    final session = ref.watch(studySessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No PDF selected.")));
    }
    final quizMap = ref.watch(quizProvider).quizzes;

    final quizzes = quizMap[session.filePath] ?? [];

    final aiState = ref.watch(aiLoadingProvider);

    final summaryState = ref.watch(summaryProvider);

    final summaries = summaryState.summaries[session.filePath] ?? [];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
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

            // SUMMARY
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed:
                      isBusy
                          ? null
                          : () {
                            if (session == null) return;

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
                    elevation: 2,
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
                              ? LoadingDots(
                                text: "Generating Summary",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF2C2C2A),
                                ),
                              )
                              : Text(
                                "Generate Summary",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF2C2C2A),
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

                if (summaries.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  ExpansionTile(
                    title: Text(
                      " Generated ${summaries.length == 1 ? 'Summary' : 'Summaries'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      for (int index = 0; index < summaries.length; index++)
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),

                          title: Text(
                            "${session.fileName} Generated Summary No. ${summaries.length - index}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text("Tap to view"),
                          onTap: () {
                            final selectedSummary = summaries[index];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SummaryScreen(
                                      documentId: session.documentId,
                                      filePath: session.filePath,
                                      fileName: session.fileName,
                                      summary: selectedSummary,
                                    ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
            ElevatedButton(
              onPressed:
                  isBusy
                      ? null
                      : () {
                        if (session == null) return;

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
                elevation: 2,
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
                          ? LoadingDots(
                            text: "Generating Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2C2C2A),
                            ),
                          )
                          : Text(
                            "Generate Quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2C2C2A),
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

            if (quizzes.isNotEmpty) ...[
              const SizedBox(height: 8),

              ExpansionTile(
                title: Text(
                  "${quizzes.length} Generated ${quizzes.length == 1 ? 'Quiz' : 'Quizzes'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                children: [
                  for (int index = 0; index < quizzes.length; index++)
                    ListTile(
                      leading: const Icon(Icons.quiz),
                      title: Text(
                        "${session.fileName} Generated Quiz No. ${quizzes.length - index}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text("Tap to start"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuizScreen(
                                  documentId: session.documentId,
                                  filePath: session.filePath,
                                  fileName: session.fileName,
                                  quiz: quizzes[index], // exact quiz clicked
                                ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            const SizedBox(height: 12),
            const Divider(
              color: Color(0xFF5F5E5A),
              thickness: 2.0, // Thickness of the line
              height:
                  20.0, // Total height allocated to the widget (includes padding)
              indent: 10.0, // Empty space to the left of the line
              endIndent: 10.0, // Empty space to the right of the line
            ),

            // TRY AGAIN BUTTON
            const SizedBox(height: 12),

            if (isFlashcardReady)
              ElevatedButton.icon(
                onPressed:
                    isBusy
                        ? null
                        : () {
                          if (session == null) return;

                          ref
                              .read(aiLoadingProvider.notifier)
                              .generateFlashcards(
                                filePath: session.filePath,
                                fileName: session.fileName,
                                documentId: session.documentId,
                              );
                        },

                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  "Generate New Flashcards",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // MAIN FLASHCARD BUTTON
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
                              builder:
                                  (_) => FlashcardScreen(
                                    filePath: session.filePath,
                                  ),
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
                elevation: 2,
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
                          ? LoadingDots(
                            text: "Generating Flashcards",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2C2C2A),
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
                          : Text(
                            "Generate Flashcards",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF2C2C2A),
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
              child: Text(
                "Ask AI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF2C2C2A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
