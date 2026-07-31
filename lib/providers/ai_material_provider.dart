import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_material_state.dart';
import '../models/study_session.dart';

class AiMaterialNotifier
    extends Notifier<Map<String, AiMaterialState>> {
  @override
  Map<String, AiMaterialState> build() {
    return {};
  }

  void addMaterial(StudySession session) {
    state = {
      ...state,
      session.filePath: AiMaterialState(
        session: session,
      ),
    };
  }

  AiMaterialState? getMaterial(String filePath) {
    return state[filePath];
  }

  void setSummaryReady(String filePath) {
    final material = state[filePath];

    if (material == null) return;

    state = {
      ...state,
      filePath: material.copyWith(
        summaryReady: true,
      ),
    };
  }

  void setQuizReady(String filePath) {
    final material = state[filePath];

    if (material == null) return;

    state = {
      ...state,
      filePath: material.copyWith(
        quizReady: true,
      ),
    };
  }

  void setFlashcardsReady(String filePath) {
    final material = state[filePath];

    if (material == null) return;

    state = {
      ...state,
      filePath: material.copyWith(
        flashcardsReady: true,
      ),
    };
  }
}

final aiMaterialProvider = NotifierProvider<
    AiMaterialNotifier,
    Map<String, AiMaterialState>>(
  AiMaterialNotifier.new,
);