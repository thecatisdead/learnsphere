import 'package:drift/drift.dart';

import 'app_database.dart';

class PlannerRepository {
  final AppDatabase db;

  PlannerRepository(this.db);

  // ============================================================
  // GET ALL PLANNER TASKS
  // ============================================================

  Future<List<PlannerTask>> getAllTasks() async {
    return await (db.select(db.plannerTasks)
      ..orderBy([(task) => OrderingTerm(expression: task.studyDate)])).get();
  }

  // ============================================================
  // ADD TASK
  // ============================================================

  Future<void> addTask({
    required String documentId,
    required DateTime studyDate,
  }) async {
    // Prevent the same PDF from being added twice.
    final existing =
        await (db.select(db.plannerTasks)..where(
          (task) => task.documentId.equals(documentId),
        )).getSingleOrNull();

    if (existing != null) {
      return;
    }

    await db
        .into(db.plannerTasks)
        .insert(
          PlannerTasksCompanion.insert(
            documentId: documentId,
            studyDate: studyDate,
          ),
        );
  }

  // ============================================================
  // DELETE TASK
  // ============================================================

  Future<void> deleteTask(int taskId) async {
    await (db.delete(db.plannerTasks)
      ..where((task) => task.id.equals(taskId))).go();
  }

  // ============================================================
  // UPDATE DATE
  // ============================================================

  Future<void> updateStudyDate({
    required int taskId,
    required DateTime studyDate,
  }) async {
    await (db.update(db.plannerTasks)..where(
      (task) => task.id.equals(taskId),
    )).write(PlannerTasksCompanion(studyDate: Value(studyDate)));
  }
}
