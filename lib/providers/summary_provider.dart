import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/summary.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class SummaryState {
  final Map<String, List<SummaryModel>> summaries;
  final bool isLoading;
  final bool hasLoaded;

  const SummaryState({
    this.summaries = const {},
    this.isLoading = false,
    this.hasLoaded = false,
  });
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

  Future<void> loadAllSummaries() async {
    if (state.hasLoaded) {
      print("Summaries already loaded into Riverpod");
      return;
    }

    state = SummaryState(
      summaries: state.summaries,
      isLoading: true,
      hasLoaded: false,
    );

    final repository = DocumentRepository(ref.read(databaseProvider));

    print("Loading all summaries from SQLite");

    final savedSummaries = await repository.getAllSummaries();

    final loadedSummaries = <String, List<SummaryModel>>{};

    for (final item in savedSummaries) {
      final document = await repository.getDocumentById(item.documentId);

      if (document == null) {
        continue;
      }

      final summary = SummaryModel(
        fileName: document.fileName,
        text: item.summaryText,
      );

      loadedSummaries.update(
        document.filePath,
        (existingSummaries) => [...existingSummaries, summary],
        ifAbsent: () => [summary],
      );
    }

    state = SummaryState(
      summaries: loadedSummaries,
      isLoading: false,
      hasLoaded: true,
    );

    print("All summaries loaded into Riverpod");
    print("Documents with summaries: ${loadedSummaries.length}");
  }
}

final summaryProvider = NotifierProvider<SummaryNotifier, SummaryState>(
  SummaryNotifier.new,
);
