import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_card/flip_card.dart';
import '/app/main_navigation.dart';

import '../../providers/flashcard_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(flashcardProvider);

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
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentIndex > 0) {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    },
                    child: const Text("Back"),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Expanded(
                    child: ElevatedButton.icon(
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
                      icon: Icon(isLastCard ? Icons.home : Icons.arrow_forward),
                      label: Text(isLastCard ? "Go Home" : "Next"),
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
