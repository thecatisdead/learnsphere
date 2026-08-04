import 'package:drift/drift.dart';

class Documents extends Table {
  TextColumn get id => text()();

  TextColumn get fileName => text()();

  TextColumn get filePath => text()();

  // SHA-256 hash of the PDF contents.
  // This lets us recognize the same PDF after it is removed and uploaded again.
  TextColumn get contentHash => text().unique()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}