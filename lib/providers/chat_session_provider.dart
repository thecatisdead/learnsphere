import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import 'package:learnsphere/database/chat_repository.dart';
import 'package:learnsphere/database/database_provider.dart';
import 'package:uuid/uuid.dart';

class ChatSessionsNotifier extends Notifier<List<ChatSession>> {
  @override
  List<ChatSession> build() {
    return [];
  }

  Future<String> createChat({
    required String fileName,
    required String filePath,
  }) async {
    final chatId = const Uuid().v4();

    final repository = ChatRepository(ref.read(databaseProvider));

    await repository.createSession(
      id: chatId,
      fileName: fileName,
      filePath: filePath,
      title: "New Chat",
    );

    final chat = ChatSession(
      id: chatId,
      fileName: fileName,
      filePath: filePath,
      title: "New Chat",
      messages: [],
    );

    state = [...state, chat];

    return chatId;
  }

  List<ChatSession> getChatsForFile(String fileName) {
    return state.where((chat) => chat.fileName == fileName).toList();
  }

  Future<void> loadChat(String chatId) async {
    print("🔍 CLICKED CHAT ID: $chatId");

    final repository = ChatRepository(ref.read(databaseProvider));

    final sessions = await repository.getSessions();

    print("🔍 SQLITE COUNT: ${sessions.length}");

    for (final session in sessions) {
      print("🔍 SQLITE CHAT: ${session.id} | ${session.title}");
    }

    final matchingSessions =
        sessions.where((session) => session.id == chatId).toList();

    if (matchingSessions.isEmpty) {
      print("❌ CHAT NOT FOUND IN SQLITE: $chatId");
      return;
    }

    final session = matchingSessions.first;

    print("✅ SQLITE CHAT FOUND: ${session.id}");

    final messages = await repository.getMessages(chatId);

    final chatMessages =
        messages.map((message) {
          return ChatMessage(
            text: message.messageText,
            isUser: message.isUser,
            createdAt: DateTime.now(),
          );
        }).toList();

    final chat = ChatSession(
      id: session.id,
      fileName: session.fileName,
      filePath: session.filePath,
      title: session.title,
      messages: chatMessages,
    );

    final chatIndex = state.indexWhere((chat) => chat.id == chatId);

    if (chatIndex == -1) {
      state = [...state, chat];
    } else {
      final updatedChats = [...state];
      updatedChats[chatIndex] = chat;
      state = updatedChats;
    }

    print("✅ CHAT LOADED: ${chat.id} | ${chat.messages.length} messages");
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
