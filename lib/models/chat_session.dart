import 'chat_message.dart';

class ChatSession {
  final String id;
  final String documentId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.documentId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });
}