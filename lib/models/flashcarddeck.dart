import 'flashcard.dart';


class FlashcardDeck {
  final String fileName;
  final List<Flashcard> flashcards;

  const FlashcardDeck({
    required this.fileName,
    required this.flashcards,
  });
}