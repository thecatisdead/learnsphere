import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcarddeck.dart';
import '../database/document_repository.dart';


import '../database/database_provider.dart';

class FlashcardState {
  final Map<String, FlashcardDeck> flashcards;
  final bool hasLoaded;

  const FlashcardState({
    this.flashcards = const {},
    this.hasLoaded = false,
  });
}

class FlashcardNotifier extends Notifier<FlashcardState> {
  @override
  FlashcardState build() {
    return const FlashcardState();
  }

  // Store one flashcard deck for each PDF.
  void setFlashcardDeck(
    String filePath,
    FlashcardDeck deck,
  ) {
    state = FlashcardState(
      flashcards: {
        ...state.flashcards,
        filePath: deck,
      },
      hasLoaded: state.hasLoaded,
    );
  }

  FlashcardDeck? getFlashcardDeck(String filePath) {
    return state.flashcards[filePath];
  }

  // Load all flashcards from SQLite only once.
  Future<void> loadAllFlashcards() async {
    if (state.hasLoaded) {
      print("Flashcards already loaded into Riverpod");
      return;
    }

    final repository = DocumentRepository(
      ref.read(databaseProvider),
    );

    print("Loading all flashcards from SQLite");

    final savedFlashcards =
        await repository.getAllFlashcards();

    final loadedFlashcards =
        <String, FlashcardDeck>{};

    for (final item in savedFlashcards) {
      final document = await repository.getDocumentById(
        item.documentId,
      );

      if (document == null) {
        continue;
      }

      loadedFlashcards[document.filePath] = item.deck;
    }

    state = FlashcardState(
      flashcards: loadedFlashcards,
      hasLoaded: true,
    );

    print("All flashcards loaded into Riverpod");
    print(
      "Documents with flashcards: ${loadedFlashcards.length}",
    );
  }

  void clearFlashcards(String filePath) {
    final newFlashcards = {...state.flashcards};

    newFlashcards.remove(filePath);

    state = FlashcardState(
      flashcards: newFlashcards,
      hasLoaded: state.hasLoaded,
    );
  }

  void clearAll() {
    state = const FlashcardState();
  }
}

final flashcardProvider =
    NotifierProvider<FlashcardNotifier, FlashcardState>(
  FlashcardNotifier.new,
);