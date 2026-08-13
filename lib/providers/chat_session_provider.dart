import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnsphere/database/chat_repository.dart';
import 'package:learnsphere/database/database_provider.dart';
import 'package:learnsphere/models/chat_message.dart';
import 'package:learnsphere/models/chat_session.dart';
import 'package:uuid/uuid.dart';

class ChatSessionsNotifier extends Notifier<ChatSessionsState> {
  @override
  ChatSessionsState build() {
    return const ChatSessionsState();
  }

  Future<String> createChat({required String documentId}) async {
    final chatId = const Uuid().v4();
    final now = DateTime.now();

    final repository = ChatRepository(ref.read(databaseProvider));

    await repository.createSession(
      id: chatId,
      documentId: documentId,
      title: "New Chat",
    );

    final chat = ChatSession(
      id: chatId,
      documentId: documentId,
      title: "New Chat",
      messages: [],
      createdAt: now,
      updatedAt: now,
    );

    // New chats go to the top.
    state = ChatSessionsState(
      chats: [chat, ...state.chats],
      hasLoaded: state.hasLoaded,
    );

    return chatId;
  }

  // --------------------------------------------------
  // LOAD ALL CHATS FROM SQLITE
  // --------------------------------------------------

  Future<void> loadAllChats() async {
    if (state.hasLoaded) {
      print("Chats already loaded into Riverpod");
      return;
    }
    final repository = ChatRepository(ref.read(databaseProvider));

    final sessions = await repository.getSessions();

    final chats = <ChatSession>[];

    for (final session in sessions) {
      final messages = await repository.getMessages(session.id);

      final chatMessages =
          messages.map((message) {
            return ChatMessage(
              text: message.messageText,
              isUser: message.isUser,
              createdAt: message.createdAt,
            );
          }).toList();

      chats.add(
        ChatSession(
          id: session.id,
          documentId: session.documentId,
          title: session.title,
          messages: chatMessages,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
        ),
      );
    }

    state = ChatSessionsState(chats: chats, hasLoaded: true);

    print("LOADED ${chats.length} CHATS FROM SQLITE");
  }

  // --------------------------------------------------
  // GET CHATS FOR DOCUMENT
  // --------------------------------------------------

  List<ChatSession> getChatsForDocument(String documentId) {
    return state.chats.where((chat) => chat.documentId == documentId).toList();
  }

  // --------------------------------------------------
  // LOAD ONE CHAT
  // --------------------------------------------------

  Future<void> loadChat(String chatId) async {
    print("🔍 LOADING CHAT: $chatId");

    final repository = ChatRepository(ref.read(databaseProvider));

    final sessions = await repository.getSessions();

    final matchingSessions =
        sessions.where((session) => session.id == chatId).toList();

    if (matchingSessions.isEmpty) {
      print("❌ CHAT NOT FOUND: $chatId");
      return;
    }

    final session = matchingSessions.first;

    final messages = await repository.getMessages(chatId);

    final chatMessages =
        messages.map((message) {
          return ChatMessage(
            text: message.messageText,
            isUser: message.isUser,
            createdAt: message.createdAt,
          );
        }).toList();

    final chat = ChatSession(
      id: session.id,
      documentId: session.documentId,
      title: session.title,
      messages: chatMessages,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    );

    final chatIndex = state.chats.indexWhere((chat) => chat.id == chatId);

    if (chatIndex == -1) {
      state = ChatSessionsState(
        chats: [chat, ...state.chats],
        hasLoaded: state.hasLoaded,
      );
    } else {
      final updatedChats = [...state.chats];

      updatedChats.removeAt(chatIndex);
      updatedChats.insert(0, chat);

      state = ChatSessionsState(
        chats: updatedChats,
        hasLoaded: state.hasLoaded,
      );
    }

    print("CHAT LOADED: ${chat.id} | ${chat.messages.length} messages");
  }

  // --------------------------------------------------
  // ADD MESSAGE
  // --------------------------------------------------

  void addMessage({required String chatId, required ChatMessage message}) {
    final chatIndex = state.chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) {
      return;
    }

    final chat = state.chats[chatIndex];
    final updatedMessages = [...chat.messages, message];

    final updatedTitle =
        chat.messages.isEmpty && message.isUser ? message.text : chat.title;

    final updatedChat = ChatSession(
      id: chat.id,
      documentId: chat.documentId,
      title: updatedTitle,
      messages: updatedMessages,
      createdAt: chat.createdAt,
      updatedAt: DateTime.now(),
    );

    final updatedChats = [...state.chats];
    updatedChats.removeAt(chatIndex);

    // Most recently used chat goes to the top.
    updatedChats.insert(0, updatedChat);

    state = ChatSessionsState(chats: updatedChats, hasLoaded: state.hasLoaded);
  }
}

class ChatSessionsState {
  final List<ChatSession> chats;
  final bool hasLoaded;

  const ChatSessionsState({this.chats = const [], this.hasLoaded = false});
}

final chatSessionsProvider =
    NotifierProvider<ChatSessionsNotifier, ChatSessionsState>(
      ChatSessionsNotifier.new,
    );
