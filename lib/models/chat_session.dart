import 'chat_message.dart';

class ChatSession {
  final String id;
  final String fileName;
  final String filePath;
  final String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.title,
    required this.messages,
  });
}