import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../database/document_repository.dart';
import '../../database/database_provider.dart';

class RecentMaterialsState {
  final List<StudySession> materials;
  final bool hasLoaded;

  const RecentMaterialsState({
    this.materials = const [],
    this.hasLoaded = false,
  });
}

class RecentMaterialsNotifier extends Notifier<RecentMaterialsState> {
  @override
  RecentMaterialsState build() {
    return const RecentMaterialsState();
  }

  Future<void> loadMaterials() async {
    if (state.hasLoaded) {
      print("Materials already loaded into Riverpod");
      return;
    }

    final repository = DocumentRepository(
      ref.read(databaseProvider),
    );

    final documents = await repository.getDocuments();

    final materials =
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

    state = RecentMaterialsState(
      materials: materials,
      hasLoaded: true,
    );

    print("LOADED MATERIALS: ${state.materials.length}");

    for (final material in state.materials) {
      print("${material.fileName} | ${material.filePath}");
    }
  }

  bool addMaterial(StudySession session) {
    if (state.materials.length >= maxMaterials) {
      return false;
    }

    state = RecentMaterialsState(
      materials: [...state.materials, session],
      hasLoaded: state.hasLoaded,
    );

    return true;
  }

  Future<void> removeMaterial(String documentId) async {
    final repository = DocumentRepository(
      ref.read(databaseProvider),
    );

    await repository.deleteDocument(documentId);

    state = RecentMaterialsState(
      materials: state.materials
          .where(
            (material) => material.documentId != documentId,
          )
          .toList(),
      hasLoaded: state.hasLoaded,
    );

    print("MATERIAL REMOVED: $documentId");
  }

  void clearMaterials() {
    state = RecentMaterialsState(
      materials: const [],
      hasLoaded: state.hasLoaded,
    );
  }
}

final recentMaterialsProvider =
    NotifierProvider<
      RecentMaterialsNotifier,
      RecentMaterialsState
    >(
      RecentMaterialsNotifier.new,
    );

const int maxMaterials = 10;