import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcarddeck.dart';

final flashcardProvider =
    NotifierProvider<FlashcardNotifier, FlashcardDeck?>(
      FlashcardNotifier.new,
    );

class FlashcardNotifier extends Notifier<FlashcardDeck?> {
  @override
  FlashcardDeck? build() {
    return null;
  }

  void setFlashcardDeck(FlashcardDeck deck) {
    state = deck;
  }

  void clearFlashcardDeck() {
    state = null;
  }
}