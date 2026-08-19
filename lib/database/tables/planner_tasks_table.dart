import 'package:drift/drift.dart';

class PlannerTasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get documentId => text()();

  DateTimeColumn get studyDate => dateTime()();
}