import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pdf_text_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/ai_loading_provider.dart';
import 'package:learnsphere/services/ai_service.dart';
import '../../shared/widgets/loadingdots_widget.dart';
import '../../models/chat_session.dart';
import '../../providers/chat_session_provider.dart';

import 'package:learnsphere/database/chat_repository.dart';
import 'package:learnsphere/database/database_provider.dart';

class StudyChatScreen extends ConsumerStatefulWidget {
  final String fileName;
  final String filePath;
  final String chatId;

  const StudyChatScreen({
    super.key,
    required this.fileName,
    required this.filePath,
    required this.chatId,
  });
  @override
  ConsumerState<StudyChatScreen> createState() => _StudyChatScreenState();
}

class _StudyChatScreenState extends ConsumerState<StudyChatScreen> {
  late String selectedChatId;

  ChatSession get currentChatSession {
    final chats = ref.read(chatSessionsProvider);

    return chats.firstWhere((chat) => chat.id == selectedChatId);
  }

  @override
  void initState() {
    super.initState();

    selectedChatId = widget.chatId;
  }

  Future<void> createNewChat() async {
    final session = ref.read(studySessionProvider);

    if (session == null) {
      return;
    }

    final newChatId = await ref
        .read(chatSessionsProvider.notifier)
        .createChat(fileName: session.fileName, filePath: session.filePath);

    if (!mounted) return;

    setState(() {
      selectedChatId = newChatId;
    });

    print("🆕 NEW CHAT CREATED: $newChatId");
  }

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

    final message = ChatMessage(
      text: question,
      isUser: true,
      createdAt: DateTime.now(),
    );

    ref
        .read(chatSessionsProvider.notifier)
        .addMessage(chatId: selectedChatId, message: message);

    final repository = ChatRepository(ref.read(databaseProvider));

    await repository.saveMessage(
      chatId: selectedChatId,
      text: question,
      isUser: true,
    );

    setState(() {
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
    print("ASK AI CALLED");

    try {
      final answer = await AiService.askAboutPdf(
        fileName: fileName,
        question: question,
      );

      if (!mounted) return;

      final message = ChatMessage(
        text: answer,
        isUser: false,
        createdAt: DateTime.now(),
      );

      ref
          .read(chatSessionsProvider.notifier)
          .addMessage(chatId: selectedChatId, message: message);

      final repository = ChatRepository(ref.read(databaseProvider));

      await repository.saveMessage(
        chatId: selectedChatId,
        text: answer,
        isUser: false,
      );
      final savedMessages = await repository.getMessages(selectedChatId);

      for (final message in savedMessages) {
        print(
          '💾 SQLITE: ${message.chatId} | ${message.messageText} | isUser=${message.isUser}',
        );
      }

      setState(() {});

      scrollToBottom();
    } catch (e) {
      if (!mounted) return;

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
    final chats = ref.watch(chatSessionsProvider);

    print("CHAT COUNT: ${chats.length}");

    for (final chat in chats) {
      print("CHAT: ${chat.id} | MESSAGES: ${chat.messages.length}");
    }

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No PDF selected.")));
    }

    print("CURRENT CHAT ID: ${currentChatSession.id}");
    print("CURRENT CHAT TITLE: ${currentChatSession.title}");

    // final pdfText = ref
    //     .read(pdfTextProvider.notifier)
    //     .getText(session.filePath);

    // print(pdfText == null ? "PDF text is not cached" : "PDF text is cached");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask AI"),
        actions: [
          IconButton(onPressed: createNewChat, icon: const Icon(Icons.add)),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Recents",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(),

              Expanded(
                child: Builder(
                  builder: (context) {
                    final chats = ref
                        .watch(chatSessionsProvider.notifier)
                        .getChatsForFile(session.fileName);

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];

                        return ListTile(
                          title: Text(chat.title),
                          subtitle: Text("${chat.messages.length} messages"),
                          selected: chat.id == selectedChatId,
                          onTap: () {
                            setState(() {
                              selectedChatId = chat.id;
                            });

                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),

              itemCount:
                  currentChatSession.messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == currentChatSession.messages.length && isLoading) {
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
                      currentChatSession.messages[index].isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          currentChatSession.messages[index].isUser
                              ? Colors.blue
                              : Colors.grey.shade200,
                    ),
                    child: Text(
                      currentChatSession.messages[index].text,
                      style: TextStyle(
                        color:
                            currentChatSession.messages[index].isUser
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
