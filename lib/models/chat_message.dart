class ChatMessage {
  final int? id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}