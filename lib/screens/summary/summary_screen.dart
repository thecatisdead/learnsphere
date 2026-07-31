import 'package:flutter/material.dart';
import '../../providers/summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../providers/study_session_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summaryProvider);
    final session = ref.watch(studySessionProvider);

    final summary = session == null ? null : summaries[session.filePath];
    return Scaffold(
      appBar: AppBar(title: const Text('Summary Screen')),
      body:
          summary == null
              ? const Center(child: Text("No summary generated yet."))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    summary.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
    );
  }
}
