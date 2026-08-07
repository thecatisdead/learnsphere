import 'package:drift/drift.dart';

class Summaries extends Table {
  TextColumn get documentId => text()();

  TextColumn get summaryText => text()();

  @override
  Set<Column> get primaryKey => {documentId};
}