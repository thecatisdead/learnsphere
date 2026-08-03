import 'package:drift/drift.dart';

import 'app_database.dart';

class ChatRepository {
  final AppDatabase db;

  ChatRepository(this.db);

  Future<void> createSession({
    required String id,
    required String fileName,
    required String filePath,
    required String title,
  }) async {
    await db.into(db.chatSessions).insert(
      ChatSessionsCompanion.insert(
        id: id,
        fileName: fileName,
        filePath: filePath,
        title: title,
      ),
    );
  }

  Future<List<ChatSession>> getSessions() {
    return db.select(db.chatSessions).get();
  }

  Future<void> saveMessage({
    required String chatId,
    required String text,
    required bool isUser,
  }) async {
    await db.into(db.chatMessages).insert(
      ChatMessagesCompanion.insert(
        chatId: chatId,
        messageText: text,
        isUser: isUser,
      ),
    );
  }

  Future<List<ChatMessage>> getMessages(String chatId) {
    return (db.select(db.chatMessages)
          ..where((message) => message.chatId.equals(chatId))
          ..orderBy([
            (message) => OrderingTerm.asc(message.id),
          ]))
        .get();
  }
}