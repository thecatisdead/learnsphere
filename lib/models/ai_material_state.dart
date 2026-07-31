import 'package:learnsphere/models/study_session.dart';

class AiMaterialState {
  final StudySession session;

  final bool summaryReady;
  final bool quizReady;
  final bool flashcardsReady;

  const AiMaterialState({
    required this.session,
    this.summaryReady = false,
    this.quizReady = false,
    this.flashcardsReady = false,
  });

  AiMaterialState copyWith({
    bool? summaryReady,
    bool? quizReady,
    bool? flashcardsReady,
  }) {
    return AiMaterialState(
      session: session,
      summaryReady: summaryReady ?? this.summaryReady,
      quizReady: quizReady ?? this.quizReady,
      flashcardsReady: flashcardsReady ?? this.flashcardsReady,
    );
  }
}