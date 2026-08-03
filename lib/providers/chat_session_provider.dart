import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatSessionsNotifier extends Notifier<List<ChatSession>> {
  @override
  List<ChatSession> build() {
    return [];
  }

  void createChat({required String fileName, required String filePath}) {
    final chat = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      filePath: filePath,
      title: "New Chat",
      messages: [],
    );

    state = [...state, chat];
  }

  List<ChatSession> getChatsForFile(String fileName) {
    return state.where((chat) => chat.fileName == fileName).toList();
  }

  void addMessage({required String chatId, required ChatMessage message}) {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);

    if (chatIndex == -1) {
      return;
    }

    final chat = state[chatIndex];

    final updatedMessages = [...chat.messages, message];

    final updatedTitle =
        chat.messages.isEmpty && message.isUser ? message.text : chat.title;

    final updatedChat = ChatSession(
      id: chat.id,
      fileName: chat.fileName,
      filePath: chat.filePath,
      title: updatedTitle,
      messages: updatedMessages,
    );

    final updatedChats = [...state];

    updatedChats[chatIndex] = updatedChat;

    state = updatedChats;
  }
}

final chatSessionsProvider =
    NotifierProvider<ChatSessionsNotifier, List<ChatSession>>(
      ChatSessionsNotifier.new,
    );
