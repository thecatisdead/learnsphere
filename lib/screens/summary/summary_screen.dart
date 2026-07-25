import 'package:flutter/material.dart';
import '../../providers/summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(summaryProvider);
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
