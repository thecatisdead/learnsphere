import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_card/flip_card.dart';

import '../../providers/flashcard_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}


class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(flashcardProvider);

    if (deck == null) {
      return const Scaffold(body: Center(child: Text("No flashcards found.")));
    }

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
                  key: cardKey,
                  front: Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
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
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!cardKey.currentState!.isFront) {
                        await cardKey.currentState!.toggleCard();
                      }

                      setState(() {
                        currentIndex--;
                      });
                    },
                    child: const Text("Back"),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!cardKey.currentState!.isFront) {
                        await cardKey.currentState!.toggleCard();
                      }

                      setState(() {
                        currentIndex++;
                      });
                    },
                    child: const Text("Next"),
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
