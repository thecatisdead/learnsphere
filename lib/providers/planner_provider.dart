import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/planner_repository.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository(ref.read(databaseProvider));
});

final plannerProvider =
    AsyncNotifierProvider<PlannerNotifier, List<PlannerTask>>(
      PlannerNotifier.new,
    );

class PlannerNotifier extends AsyncNotifier<List<PlannerTask>> {
  late final PlannerRepository repository;

  @override
  Future<List<PlannerTask>> build() async {
    repository = ref.read(plannerRepositoryProvider);

    return await repository.getAllTasks();
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> addTask({
    required String documentId,
    required DateTime studyDate,
  }) async {
    await repository.addTask(documentId: documentId, studyDate: studyDate);

    state = AsyncData(await repository.getAllTasks());
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteTask(int taskId) async {
    await repository.deleteTask(taskId);

    state = AsyncData(await repository.getAllTasks());
  }

  // ============================================================
  // UPDATE DATE
  // ============================================================

  Future<void> updateStudyDate({
    required int taskId,
    required DateTime studyDate,
  }) async {
    await repository.updateStudyDate(taskId: taskId, studyDate: studyDate);

    state = AsyncData(await repository.getAllTasks());
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    state = AsyncData(await repository.getAllTasks());
  }
}
