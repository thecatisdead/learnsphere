import 'package:flutter/material.dart';
import 'package:learnsphere/screens/summary/summary_screen.dart';
import '/../screens/quiz/quiz_screen.dart';

class StudyMaterialScreen extends StatelessWidget {
  final String fileName;

  const StudyMaterialScreen({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
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
                title: Text(fileName),
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
                Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => SummaryScreen(),
                ));
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
                    builder: (context) => QuizScreen(fileName: fileName),
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
