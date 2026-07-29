import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiTask { none, summary, quiz, flashcards }

final aiLoadingProvider = NotifierProvider<AiLoadingNotifier, AiTask>(
  AiLoadingNotifier.new,
);

class AiLoadingNotifier extends Notifier<AiTask> {
  @override
  AiTask build() {
    return AiTask.none;
  }

  void setLoading(AiTask task) {
    state = task;
  }

  void clearLoading() {
    state = AiTask.none;
  }
}
