import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';

class RecentMaterialsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return [];
  }

  bool addMaterial(StudySession session) {
    if (state.length >= maxMaterials) {
      return false;
    }

    state = [...state, session];
    return true;
  }

  void clearMaterials() {
    state = [];
  }
}

final recentMaterialsProvider =
    NotifierProvider<RecentMaterialsNotifier, List<StudySession>>(
      RecentMaterialsNotifier.new,
    );

const int maxMaterials = 5;
