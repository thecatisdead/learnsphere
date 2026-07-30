import '../../providers/ai_loading_provider.dart';

class AiGenerationState {
  final AiTask task;
  final AiTaskStatus status;

  const AiGenerationState({required this.task, required this.status});

  AiGenerationState copyWith({AiTask? task, AiTaskStatus? status}) {
    return AiGenerationState(
      task: task ?? this.task,
      status: status ?? this.status,
    );
  }
}
