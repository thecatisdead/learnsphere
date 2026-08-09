import 'package:drift/drift.dart';

class Quizzes extends Table {
  TextColumn get documentId => text()();
  TextColumn get quizJson => text()();

  @override
  Set<Column> get primaryKey => {documentId};
}