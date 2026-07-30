import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_generation_state.dart';

enum AiTask { none, summary, questions, flashcards }

enum AiTaskStatus { idle, generating, ready, error }

final aiLoadingProvider =
    NotifierProvider<AiLoadingNotifier, AiGenerationState>(
      AiLoadingNotifier.new,
    );

class AiLoadingNotifier extends Notifier<AiGenerationState> {
  @override
  AiGenerationState build() {
    return const AiGenerationState(
      task: AiTask.none,
      status: AiTaskStatus.idle,
    );
  }

  void start(AiTask task) {
    state = state.copyWith(task: task, status: AiTaskStatus.generating);
  }

  void finish() {
    state = state.copyWith(status: AiTaskStatus.ready);
  }

  void reset() {
    state = const AiGenerationState(
      task: AiTask.none,
      status: AiTaskStatus.idle,
    );
  }

  void error() {
    state = state.copyWith(status: AiTaskStatus.error);
  }
}
