import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatState {
  final String? documentId;
  final String? fileName;
  final String? filePath;
  final String? chatId;

  const AiChatState({
    this.documentId,
    this.fileName,
    this.filePath,
    this.chatId,
  });

  bool get hasSelectedPdf =>
      documentId != null &&
      fileName != null &&
      filePath != null &&
      chatId != null;

  AiChatState copyWith({
    String? documentId,
    String? fileName,
    String? filePath,
    String? chatId,
  }) {
    return AiChatState(
      documentId: documentId ?? this.documentId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      chatId: chatId ?? this.chatId,
    );
  }
}

class AiChatStateNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return const AiChatState();
  }

  void changeChat(String chatId) {
    state = state.copyWith(chatId: chatId);
  }

  void selectPdf({
    required String documentId,
    required String fileName,
    required String filePath,
    required String chatId,
  }) {
    state = AiChatState(
      documentId: documentId,
      fileName: fileName,
      filePath: filePath,
      chatId: chatId,
    );
  }

  void clearSelection() {
    state = const AiChatState();
  }
}

final aiChatStateProvider = NotifierProvider<AiChatStateNotifier, AiChatState>(
  AiChatStateNotifier.new,
);
