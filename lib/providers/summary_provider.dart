import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/summary.dart';



class SummaryNotifier extends Notifier<Summary?> {
  @override
  Summary? build() {
    return null;
  }

  void setSummary(Summary summary) {
    state = summary;
  }

  void clearSummary() {
    state = null;
  }
}

final summaryProvider =
    NotifierProvider<SummaryNotifier, Summary?>(
      SummaryNotifier.new,
    );