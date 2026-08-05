import 'package:drift/drift.dart';

class Documents extends Table {
  TextColumn get id => text()();

  TextColumn get fileName => text()();

  TextColumn get filePath => text()();

  // SHA-256 hash of the PDF contents.
  TextColumn get contentHash => text().unique()();

  // AI generation state
  BoolColumn get summaryGenerated =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get quizGenerated =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get flashcardsGenerated =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}