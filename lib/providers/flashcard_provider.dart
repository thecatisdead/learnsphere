import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcarddeck.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class FlashcardNotifier
    extends Notifier<Map<String, FlashcardDeck>> {
  @override
  Map<String, FlashcardDeck> build() {
    return {};
  }

  void setFlashcardDeck(
    String filePath,
    FlashcardDeck deck,
  ) {
    state = {
      ...state,
      filePath: deck,
    };
  }

  FlashcardDeck? getFlashcardDeck(String filePath) {
    return state[filePath];
  }

  Future<void> loadFlashcards({
    required String documentId,
    required String filePath,
  }) async {
    print("LOAD FLASHCARDS CALLED");
    print("Document ID: $documentId");

    final repository = DocumentRepository(
      ref.read(databaseProvider),
    );

    final savedFlashcards =
        await repository.getFlashcards(documentId);

    print("SQLite flashcard query finished");

    if (savedFlashcards == null) {
      print(" No flashcards found in SQLite");
      return;
    }

    print("Flashcards found in SQLite");
    print(
      "Card count: ${savedFlashcards.flashcards.length}",
    );

    setFlashcardDeck(
      filePath,
      savedFlashcards,
    );

    print("⚡ Flashcards loaded into Riverpod");
  }

  void clearFlashcards(String filePath) {
    final newState = {...state};
    newState.remove(filePath);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

final flashcardProvider =
    NotifierProvider<
        FlashcardNotifier,
        Map<String, FlashcardDeck>>(
  FlashcardNotifier.new,
);