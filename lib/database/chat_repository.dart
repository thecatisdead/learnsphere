import 'package:drift/drift.dart';

import 'app_database.dart';

class ChatRepository {
  final AppDatabase db;

  ChatRepository(this.db);

  // --------------------------------------------------
  // CREATE CHAT
  // --------------------------------------------------

  Future<void> createSession({
    required String id,
    required String documentId,
    required String title,
  }) async {
    final now = DateTime.now();

    await db
        .into(db.chatSessions)
        .insert(
          ChatSessionsCompanion.insert(
            id: id,
            documentId: documentId,
            title: title,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // --------------------------------------------------
  // UPDATE CHAT TITLE
  // --------------------------------------------------

  Future<void> updateSessionTitle({
    required String chatId,
    required String title,
  }) async {
    await (db.update(db.chatSessions)
      ..where((session) => session.id.equals(chatId))).write(
      ChatSessionsCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --------------------------------------------------
  // GET ALL CHATS
  // Newest/most recently used first
  // --------------------------------------------------

  Future<List<ChatSession>> getSessions() {
    return (db.select(db.chatSessions)
      ..orderBy([(chat) => OrderingTerm.desc(chat.updatedAt)])).get();
  }

  // --------------------------------------------------
  // GET CHATS FOR A DOCUMENT
  // --------------------------------------------------

  Future<List<ChatSession>> getChatsForDocument(String documentId) {
    return (db.select(db.chatSessions)
          ..where((chat) => chat.documentId.equals(documentId))
          ..orderBy([(chat) => OrderingTerm.desc(chat.updatedAt)]))
        .get();
  }

  // --------------------------------------------------
  // GET MOST RECENT CHAT FOR A DOCUMENT
  // --------------------------------------------------

  Future<ChatSession?> getLatestChatForDocument(String documentId) {
    return (db.select(db.chatSessions)
          ..where((chat) => chat.documentId.equals(documentId))
          ..orderBy([(chat) => OrderingTerm.desc(chat.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  // --------------------------------------------------
  // SAVE MESSAGE
  // --------------------------------------------------

  Future<void> saveMessage({
    required String chatId,
    required String text,
    required bool isUser,
    String? title,
  }) async {
    final now = DateTime.now();

    await db
        .into(db.chatMessages)
        .insert(
          ChatMessagesCompanion.insert(
            chatId: chatId,
            messageText: text,
            isUser: isUser,
            createdAt: now,
          ),
        );

    await (db.update(db.chatSessions)
      ..where((chat) => chat.id.equals(chatId))).write(
      ChatSessionsCompanion(
        updatedAt: Value(now),
        title: title != null ? Value(title) : const Value.absent(),
      ),
    );
  }

  // --------------------------------------------------
  // GET MESSAGES
  // --------------------------------------------------

  Future<List<ChatMessage>> getMessages(String chatId) {
    return (db.select(db.chatMessages)
          ..where((message) => message.chatId.equals(chatId))
          ..orderBy([(message) => OrderingTerm.asc(message.id)]))
        .get();
  }
}
