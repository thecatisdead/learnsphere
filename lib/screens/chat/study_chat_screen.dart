import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pdf_text_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/ai_loading_provider.dart';
import 'package:learnsphere/services/ai_service.dart';
import '../../shared/widgets/loadingdots_widget.dart';

class StudyChatScreen extends ConsumerStatefulWidget {
  final String fileName;
  final String filePath;

  const StudyChatScreen({
    super.key,
    required this.fileName,
    required this.filePath,
  });

  @override
  ConsumerState<StudyChatScreen> createState() => _StudyChatScreenState();
}

class _StudyChatScreenState extends ConsumerState<StudyChatScreen> {
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  bool isLoading = false;
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<ChatMessage> messages = [];

  Future<void> sendMessage() async {
    print("🔥 SEND MESSAGE CALLED");

    final question = controller.text;

    if (question.trim().isEmpty || isLoading) {
      return;
    }

    final session = ref.read(studySessionProvider);

    if (session == null) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(text: question, isUser: true));

      isLoading = true;
    });

    controller.clear();

    scrollToBottom();

    try {
      await askAi(question: question, fileName: session.fileName);
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      scrollToBottom();
    }
  }

  Future<void> askAi({
    required String question,
    required String fileName,
  }) async {
    print("🔥 ASK AI CALLED");

    try {
      final answer = await AiService.askAboutPdf(
        fileName: fileName,
        question: question,
      );

      if (!mounted) return;

      setState(() {
        messages.add(ChatMessage(text: answer, isUser: false));
      });

      scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add(
          const ChatMessage(
            text: "Sorry, I couldn't generate a response.",
            isUser: false,
          ),
        );
      });

      print("AI error: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(studySessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No PDF selected.")));
    }

    // final pdfText = ref
    //     .read(pdfTextProvider.notifier)
    //     .getText(session.filePath);

    // print(pdfText == null ? "PDF text is not cached" : "PDF text is cached");

    return Scaffold(
      appBar: AppBar(title: const Text("Ask AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: const LoadingDots(
                        text: "AI is thinking",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment:
                      messages[index].isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          messages[index].isUser
                              ? Colors.blue
                              : Colors.grey.shade200,
                    ),
                    child: Text(
                      messages[index].text,
                      style: TextStyle(
                        color:
                            messages[index].isUser
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Ask about this material...",
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: isLoading ? null : sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
