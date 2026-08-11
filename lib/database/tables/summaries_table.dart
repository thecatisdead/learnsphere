import 'package:drift/drift.dart';

class Summaries extends Table {
  TextColumn get id => text()();

  TextColumn get documentId => text()();

  TextColumn get summaryText => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}