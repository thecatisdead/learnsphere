import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/summary.dart';
import '../database/document_repository.dart';
import '../database/database_provider.dart';

class SummaryState {
  final Map<String, SummaryModel> summaries;
  final bool isLoading;

  const SummaryState({this.summaries = const {}, this.isLoading = false});
}

class SummaryNotifier extends Notifier<SummaryState> {
  @override
  SummaryState build() {
    return const SummaryState();
  }

  void setSummary(String filePath, SummaryModel summary) {
    state = SummaryState(
      summaries: {...state.summaries, filePath: summary},
      isLoading: state.isLoading,
    );
  }

  SummaryModel? getSummary(String filePath) {
    return state.summaries[filePath];
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

    final savedSummary = await repository.getSummary(documentId);

    print("📖 SQLite query finished");

    if (savedSummary == null) {
      print("❌ No summary found in SQLite");

      state = SummaryState(summaries: state.summaries, isLoading: false);
      return;
    }

    print("✅ Summary found in SQLite");
    print("📄 Length: ${savedSummary.summaryText.length}");
    setSummary(
      filePath,
      SummaryModel(fileName: fileName, text: savedSummary.summaryText),
    );

    state = SummaryState(summaries: state.summaries, isLoading: false);
  }
}

final summaryProvider = NotifierProvider<SummaryNotifier, SummaryState>(
  SummaryNotifier.new,
);
