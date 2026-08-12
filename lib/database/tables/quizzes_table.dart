import 'package:drift/drift.dart';

class Quizzes extends Table {
  TextColumn get id => text()();

  TextColumn get documentId => text()();

  TextColumn get quizJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}