import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_provider.dart';
import '../../database/document_repository.dart';
import '../../providers/study_session_provider.dart';
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
    print("load summary called");

    print("📄 Document ID: ${widget.documentId}");
    final summaryState = ref.read(summaryProvider);

    print("📦 Riverpod summaries: ${summaryState.summaries}");

    final cachedSummary = summaryState.summaries[widget.filePath];
    if (cachedSummary != null) {
      print("⚡ Summary found in Riverpod");

  
      return;
    }

    await ref
        .read(summaryProvider.notifier)
        .loadSummary(
          documentId: widget.documentId,
          filePath: widget.filePath,
          fileName: widget.fileName,
        );

    print("✅ STEP 2: loadSummary finished");
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryProvider);
    final summary = summaryState.summaries[widget.filePath];
    if (summaryState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Summary")),
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
