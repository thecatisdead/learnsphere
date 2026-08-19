import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/chat_sessions_table.dart';
import 'tables/chat_messages_table.dart';
import 'tables/documents_table.dart';
import 'tables/summaries_table.dart';
import 'tables/quizzes_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/planner_tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Documents,
    ChatSessions,
    ChatMessages,
    Summaries,
    Quizzes,
    Flashcards,
    PlannerTasks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },

      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(documents, documents.summaryGenerated);

          await m.addColumn(documents, documents.quizGenerated);

          await m.addColumn(documents, documents.flashcardsGenerated);
        }

        if (from < 4) {
          await m.createTable(quizzes);
        }

        if (from < 5) {
          await m.createTable(flashcards);
        }

        if (from < 6) {
          await m.createTable(plannerTasks);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(p.join(directory.path, 'learnsphere.sqlite'));

    return NativeDatabase(file);
  });
}
