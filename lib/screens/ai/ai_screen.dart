import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/database/chat_repository.dart';
import 'package:learnsphere/services/ai_service.dart';

import '../../database/database_provider.dart';
import '../../database/document_repository.dart';
import '../../database/app_database.dart' hide ChatSession, ChatMessage;

import '../../models/study_session.dart';
import '../../models/chat_session.dart';
import '../../models/chat_message.dart';

import '../../providers/study_session_provider.dart';
import '../../providers/chat_session_provider.dart';

import '../../shared/widgets/loadingdots_widget.dart';

import '../../providers/ai_chat_state_provider.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  bool isLoading = false;

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ============================================================
  // SELECT PDF
  // ============================================================

  Future<void> _selectPdf(Document document) async {
    final session = StudySession(
      documentId: document.id,
      fileName: document.fileName,
      filePath: document.filePath,
    );

    ref.read(studySessionProvider.notifier).setSession(session);

    final allChats = ref.read(chatSessionsProvider).chats;

    final pdfChats =
        allChats.where((chat) => chat.documentId == document.id).toList();

    String chatId;

    if (pdfChats.isNotEmpty) {
      // Load the most recent chat for this PDF.
      chatId = pdfChats.first.id;

      await ref.read(chatSessionsProvider.notifier).loadChat(chatId);
    } else {
      // Create the first chat for this PDF.
      chatId = await ref
          .read(chatSessionsProvider.notifier)
          .createChat(documentId: document.id);
    }

    if (!mounted) return;

    ref
        .read(aiChatStateProvider.notifier)
        .selectPdf(
          documentId: document.id,
          fileName: document.fileName,
          filePath: document.filePath,
          chatId: chatId,
        );

    setState(() {
      isLoading = false;
    });

    print("SELECTED PDF: ${document.fileName}");
    print("SELECTED CHAT: $chatId");
  }

  // ============================================================
  // GET CURRENT CHAT
  // ============================================================

  ChatSession? getCurrentChat(String chatId) {
    final chats = ref.read(chatSessionsProvider).chats;

    for (final chat in chats) {
      if (chat.id == chatId) {
        return chat;
      }
    }

    return null;
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // CREATE NEW CHAT
  // ============================================================

  Future<void> createNewChat() async {
    final session = ref.read(studySessionProvider);

    if (session == null) return;

    final newChatId = await ref
        .read(chatSessionsProvider.notifier)
        .createChat(documentId: session.documentId);

    if (!mounted) return;

    ref.read(aiChatStateProvider.notifier).changeChat(newChatId);

    print("NEW CHAT CREATED: $newChatId");
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final question = controller.text.trim();

    if (question.isEmpty || isLoading) return;

    final aiChatState = ref.read(aiChatStateProvider);

    final chatId = aiChatState.chatId;

    if (chatId == null) {
      print("NO CHAT SELECTED");
      return;
    }

    final currentChat = getCurrentChat(chatId);

    if (currentChat == null) {
      print("CURRENT CHAT NOT FOUND: $chatId");
      return;
    }

    final session = ref.read(studySessionProvider);

    if (session == null) {
      print("NO PDF SELECTED");
      return;
    }

    print("SENDING TO CHAT: $chatId");
    print("PDF: ${session.fileName}");
    print("QUESTION: $question");

    // ============================================================
    // COPY HISTORY BEFORE ADDING USER MESSAGE
    // ============================================================

    final history = List<ChatMessage>.from(currentChat.messages);

    // ============================================================
    // CREATE USER MESSAGE
    // ============================================================

    final userMessage = ChatMessage(
      text: question,
      isUser: true,
      createdAt: DateTime.now(),
    );

    // ============================================================
    // ADD USER MESSAGE TO RIVERPOD
    // ============================================================

    ref
        .read(chatSessionsProvider.notifier)
        .addMessage(chatId: chatId, message: userMessage);

    // ============================================================
    // GET UPDATED CHAT
    // ============================================================

    final updatedChat = getCurrentChat(chatId);

    final repository = ChatRepository(ref.read(databaseProvider));

    final shouldSetTitle =
        updatedChat != null && updatedChat.messages.length == 1;

    // ============================================================
    // SAVE USER MESSAGE TO SQLITE
    // ============================================================

    await repository.saveMessage(
      chatId: chatId,
      text: question,
      isUser: true,
      title: shouldSetTitle ? question : null,
    );

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    controller.clear();

    scrollToBottom();

    // ============================================================
    // ASK AI
    // ============================================================

    try {
      await askAi(
        question: question,
        fileName: session.fileName,
        history: history,
        chatId: chatId,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      scrollToBottom();
    }
  }

  // ============================================================
  // ASK AI
  // ============================================================

  Future<void> askAi({
    required String question,
    required String fileName,
    required List<ChatMessage> history,
    required String chatId,
  }) async {
    print("ASK AI CALLED");

    try {
      final stopwatch = Stopwatch()..start();

      final answer = await AiService.askAboutPdf(
        fileName: fileName,
        question: question,
        history: history,
      );

      stopwatch.stop();

      print(
        "AI RESPONSE TIME: "
        "${stopwatch.elapsedMilliseconds}ms",
      );

      if (!mounted) return;

      // ============================================================
      // CREATE AI MESSAGE
      // ============================================================

      final aiMessage = ChatMessage(
        text: answer,
        isUser: false,
        createdAt: DateTime.now(),
      );

      // ============================================================
      // ADD AI MESSAGE TO RIVERPOD
      // ============================================================

      ref
          .read(chatSessionsProvider.notifier)
          .addMessage(chatId: chatId, message: aiMessage);

      // ============================================================
      // SAVE AI MESSAGE TO SQLITE
      // ============================================================

      final repository = ChatRepository(ref.read(databaseProvider));

      await repository.saveMessage(chatId: chatId, text: answer, isUser: false);

      print("AI MESSAGE SAVED");

      scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      print("AI ERROR: $e");

      controller.text = question;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn't get a response. Please try again."),
          action: SnackBarAction(label: "RETRY", onPressed: sendMessage),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final aiChatState = ref.watch(aiChatStateProvider);

    final selectedDocumentId = aiChatState.documentId;
    final selectedChatId = aiChatState.chatId;

    final allChats = ref.watch(chatSessionsProvider).chats;

    final currentChat =
        selectedChatId == null
            ? null
            : allChats.where((chat) => chat.id == selectedChatId).firstOrNull;

    final session = ref.watch(studySessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("AI Chat")),

      // ============================================================
      // DRAWER
      // ============================================================
      drawer:
          session == null
              ? null
              : Drawer(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Recents",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed:
                                  currentChat != null &&
                                          currentChat.messages.any(
                                            (message) => message.isUser,
                                          )
                                      ? createNewChat
                                      : null,
                              icon: const Icon(Icons.add),
                              tooltip: "New Chat",
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      Expanded(
                        child: ListView(
                          children:
                              allChats
                                  .where(
                                    (chat) =>
                                        chat.documentId == session.documentId,
                                  )
                                  .map((chat) {
                                    return ListTile(
                                      title: Text(chat.title),
                                      selected: chat.id == selectedChatId,

                                      onTap: () async {
                                        await ref
                                            .read(chatSessionsProvider.notifier)
                                            .loadChat(chat.id);

                                        if (!mounted) return;

                                        ref
                                            .read(aiChatStateProvider.notifier)
                                            .changeChat(chat.id);

                                        Navigator.pop(context);
                                      },
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

      // ============================================================
      // BODY
      // ============================================================
      body: FutureBuilder<List<Document>>(
        future:
            DocumentRepository(ref.read(databaseProvider)).getAllDocuments(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load PDFs: ${snapshot.error}"),
            );
          }

          final documents = snapshot.data ?? [];

          if (documents.isEmpty) {
            return const Center(child: Text("No PDFs uploaded yet."));
          }

          return Column(
            children: [
              // ======================================================
              // PDF DROPDOWN
              // ======================================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: selectedDocumentId,
                  isExpanded: true,

                  decoration: const InputDecoration(
                    labelText: "Select a PDF",
                    prefixIcon: Icon(Icons.picture_as_pdf),
                    border: OutlineInputBorder(),
                  ),

                  items:
                      documents.map((document) {
                        return DropdownMenuItem<String>(
                          value: document.id,

                          child: Text(
                            document.fileName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),

                  onChanged: (documentId) {
                    if (documentId == null) return;

                    final document = documents.firstWhere(
                      (document) => document.id == documentId,
                    );

                    _selectPdf(document);
                  },
                ),
              ),

              const Divider(height: 1),

              // ======================================================
              // CHAT MESSAGES
              // ======================================================
              Expanded(
                child:
                    currentChat == null
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(Icons.smart_toy_outlined, size: 64),

                              SizedBox(height: 16),

                              Text(
                                "Select a PDF to start chatting.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,

                          padding: const EdgeInsets.all(16),

                          itemCount:
                              currentChat.messages.length + (isLoading ? 1 : 0),

                          itemBuilder: (context, index) {
                            // AI loading bubble
                            if (index == currentChat.messages.length &&
                                isLoading) {
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

                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final message = currentChat.messages[index];

                            return Align(
                              alignment:
                                  message.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,

                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),

                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                  color:
                                      message.isUser
                                          ? Colors.blue
                                          : Colors.grey.shade200,
                                ),

                                child: Text(
                                  message.text,

                                  style: TextStyle(
                                    color:
                                        message.isUser
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),

              // ======================================================
              // MESSAGE INPUT
              // ======================================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,

                        enabled: selectedChatId != null && !isLoading,

                        onSubmitted: (_) {
                          sendMessage();
                        },

                        decoration: const InputDecoration(
                          hintText: "Ask about this material...",
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      onPressed:
                          selectedChatId == null || isLoading
                              ? null
                              : sendMessage,

                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
