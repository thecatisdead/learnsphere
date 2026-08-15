import 'package:flutter/material.dart';

import '../../models/summary.dart';

class SummaryScreen extends StatelessWidget {
  final String documentId;
  final String filePath;
  final String fileName;
  final SummaryModel summary;

  const SummaryScreen({
    super.key,
    required this.documentId,
    required this.filePath,
    required this.fileName,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Summary"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              summary.text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}