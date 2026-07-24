import 'package:flutter/material.dart';
import 'package:learnsphere/providers/study_session_provider.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import '/../screens/quiz/quiz_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudyMaterialScreen extends ConsumerWidget {
  const StudyMaterialScreen({super.key});


  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(studySessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Study Material")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(session?.fileName ?? "No PDF Selected"),
                subtitle: const Text("Ready to study"),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Choose an AI Tool",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryScreen()),
                );
              },
              icon: const Icon(Icons.summarize),
              label: const Text("Generate Summary"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            QuizScreen(fileName: session?.fileName ?? ""),
                  ),
                );
              },
              icon: const Icon(Icons.quiz),
              label: const Text("Generate Quiz"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.style),
              label: const Text("Flashcards"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.smart_toy),
              label: const Text("AI"),
            ),
          ],
        ),
      ),
    );
  }
}
