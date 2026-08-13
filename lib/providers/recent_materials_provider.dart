import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../database/document_repository.dart';
import '../../database/database_provider.dart';
import '../providers/quiz_provider.dart';


class RecentMaterialsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return [];
  }

  Future<void> loadMaterials() async {


Future<void> loadSavedQuizzes() async {
  final repository = DocumentRepository(
    ref.read(databaseProvider),
  );

  print("Loading all quizzes from SQLite");

  await ref.read(quizProvider.notifier).loadAllQuizzes();

  print("Finished loading all quizzes");
}



    final repository = DocumentRepository(ref.read(databaseProvider));

    final documents = await repository.getDocuments();

    state =
        documents
            .take(maxMaterials)
            .map(
              (document) => StudySession(
                documentId: document.id,
                fileName: document.fileName,
                filePath: document.filePath,
              ),
            )
            .toList();

    print("📚 LOADED MATERIALS: ${state.length}");

    for (final material in state) {
      print("📄 ${material.fileName} | ${material.filePath}");
    }
  }

  bool addMaterial(StudySession session) {
    if (state.length >= maxMaterials) {
      return false;
    }

    state = [...state, session];
    return true;
  }

  Future<void> removeMaterial(String documentId) async {
    final repository = DocumentRepository(ref.read(databaseProvider));

    await repository.deleteDocument(documentId);

    state =
        state.where((material) => material.documentId != documentId).toList();

    print("🗑️ MATERIAL REMOVED: $documentId");
  }

  void clearMaterials() {
    state = [];
  }
}

final recentMaterialsProvider =
    NotifierProvider<RecentMaterialsNotifier, List<StudySession>>(
      RecentMaterialsNotifier.new,
    );

const int maxMaterials = 10;
