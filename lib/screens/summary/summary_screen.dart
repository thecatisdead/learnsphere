import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_provider.dart';
import '../../database/document_repository.dart';
import '../../providers/study_session_provider.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  String? summaryText;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final session = ref.read(studySessionProvider);

    if (session == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final repository = DocumentRepository(ref.read(databaseProvider));

    final summary = await repository.getSummary(session.documentId);

    if (!mounted) return;

    setState(() {
      summaryText = summary?.summaryText;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Summary")),
      body:
          summaryText == null
              ? const Center(child: Text("No summary generated yet."))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    summaryText!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
    );
  }
}
