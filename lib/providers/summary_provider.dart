import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/summary.dart';

class SummaryNotifier extends Notifier<Map<String, Summary>> {
  @override
  Map<String, Summary> build() {
    return {};
  }

  void setSummary(String filePath, Summary summary) {
    state = {
      ...state,
      filePath: summary,
    };
  }

  Summary? getSummary(String filePath) {
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
    NotifierProvider<SummaryNotifier, Map<String, Summary>>(
  SummaryNotifier.new,
);