import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/summary_provider.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  final String documentId;
  final String filePath;
  final String fileName;

  const SummaryScreen({
    super.key,
    required this.documentId,
    required this.filePath,
    required this.fileName,
  });

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    print("LOAD SUMMARY SCREEN");
    print("Document ID: ${widget.documentId}");

    final summaryState = ref.read(summaryProvider);

    final cachedSummaries = summaryState.summaries[widget.filePath];

    // Already loaded into Riverpod.
    if (cachedSummaries != null && cachedSummaries.isNotEmpty) {
      print("⚡ Summaries found in Riverpod");
      print(" Count: ${cachedSummaries.length}");
      return;
    }

    // Load from SQLite.
    print("Loading summaries from SQLite...");

    await ref.read(summaryProvider.notifier).loadAllSummaries();

    print("STEP: loadSummary finished");
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryProvider);

    final summaries = summaryState.summaries[widget.filePath] ?? [];

    if (summaryState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (summaries.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No summary generated yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Summary")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final summary = summaries[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Summary ${summaries.length - index}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(summary.text, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
