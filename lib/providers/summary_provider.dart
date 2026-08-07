import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/summary.dart';

class SummaryNotifier extends Notifier<Map<String, SummaryModel >> {
  @override
  Map<String, SummaryModel > build() {
    return {};
  }

  void setSummary(String filePath, SummaryModel  summary) {
    state = {
      ...state,
      filePath: summary,
    };
  }

  SummaryModel ? getSummary(String filePath) {
    return state[filePath];
  }

  void clearSummary(String filePath) {
    final newState = {...state};
    newState.remove(filePath);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

final summaryProvider =
    NotifierProvider<SummaryNotifier, Map<String, SummaryModel >>(
  SummaryNotifier.new,
);