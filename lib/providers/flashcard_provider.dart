import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcarddeck.dart';

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