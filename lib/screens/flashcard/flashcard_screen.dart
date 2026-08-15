import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_card/flip_card.dart';
import '/app/main_navigation.dart';

import '../../providers/flashcard_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String filePath;

  const FlashcardScreen({super.key, required this.filePath});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlashcards();
    });
  }

  Future<void> _loadFlashcards() async {
    print("FLASHCARD SCREEN LOAD");

    final cachedDeck = ref.read(flashcardProvider).flashcards[widget.filePath];

    if (cachedDeck != null) {
      print("Flashcards found in Riverpod");
      print("Card count: ${cachedDeck.flashcards.length}");
      return;
    }

    print("No flashcards found in Riverpod");

    print("STEP: Flashcard SQLite load finished");
  }

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(
      flashcardProvider.select((state) => state.flashcards[widget.filePath]),
    );

    if (deck == null) {
      return const Scaffold(body: Center(child: Text("No flashcards found.")));
    }

    final isLastCard = currentIndex == deck.flashcards.length - 1;

    final flashcard = deck.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(deck.fileName), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "${currentIndex + 1} / ${deck.flashcards.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: FlipCard(
                  key: ValueKey(currentIndex),

                  front: Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        flashcard.front,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  back: Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        flashcard.back,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (currentIndex > 0) {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(100, 116, 139, 1.0),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    label: const Text("Back"),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastCard) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const MainNavigation();
                            },
                          ),
                          (route) => false,
                        );
                      } else {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(13, 148, 136, 1.0),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastCard ? "Go Home" : "Next",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(width: 8),

                        Icon(isLastCard ? Icons.home : Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
