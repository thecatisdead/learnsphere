import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';

class StudySessionNotifier extends Notifier<StudySession?> {
  @override
  StudySession? build() {
    return null;
  }

  void setSession(StudySession session) {
    state = session;
  }

  void clearSession() {
    state = null;
  }
}

final studySessionProvider =
    NotifierProvider<StudySessionNotifier, StudySession?>(
      StudySessionNotifier.new,
    );
