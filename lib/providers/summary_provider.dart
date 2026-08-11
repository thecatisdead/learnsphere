import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/summary.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class SummaryState {
  final Map<String, List<SummaryModel>> summaries;
  final bool isLoading;

  const SummaryState({this.summaries = const {}, this.isLoading = false});
}

class SummaryNotifier extends Notifier<SummaryState> {
  @override
  SummaryState build() {
    return const SummaryState();
  }

  void setSummary(String filePath, SummaryModel summary) {
    final existing = state.summaries[filePath] ?? [];

    state = SummaryState(
      summaries: {
        ...state.summaries,
        filePath: [summary, ...existing],
      },
      isLoading: state.isLoading,
    );
  }

  List<SummaryModel> getSummaries(String filePath) {
    return state.summaries[filePath] ?? [];
  }

  SummaryModel? getLatestSummary(String filePath) {
    final summaries = state.summaries[filePath];

    if (summaries == null || summaries.isEmpty) {
      return null;
    }

    return summaries.first;
  }

  void clearSummary(String filePath) {
    final newSummaries = {...state.summaries};

    newSummaries.remove(filePath);

    state = SummaryState(summaries: newSummaries, isLoading: state.isLoading);
  }

  void clearAll() {
    state = SummaryState(summaries: {}, isLoading: state.isLoading);
  }

  Future<void> loadSummary({
    required String documentId,
    required String filePath,
    required String fileName,
  }) async {
    state = SummaryState(summaries: state.summaries, isLoading: true);

    final repository = DocumentRepository(ref.read(databaseProvider));

    final savedSummaries = await repository.getSummaries(documentId);

    print("SQLite query finished");

    if (savedSummaries.isEmpty) {
      print(" No summaries found in SQLite");

      state = SummaryState(summaries: state.summaries, isLoading: false);

      return;
    }

    print("Summaries found in SQLite");
    print("Summary count: ${savedSummaries.length}");

    final loadedSummaries =
        savedSummaries.map((saved) {
          return SummaryModel(fileName: fileName, text: saved.summaryText);
        }).toList();

    state = SummaryState(
      summaries: {...state.summaries, filePath: loadedSummaries},
      isLoading: false,
    );

    print("⚡ All summaries loaded into Riverpod");
  }
}

final summaryProvider = NotifierProvider<SummaryNotifier, SummaryState>(
  SummaryNotifier.new,
);
