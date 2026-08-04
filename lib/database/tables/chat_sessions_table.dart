import 'package:drift/drift.dart';

class ChatSessions extends Table {
  TextColumn get id => text()();

  // The PDF/document this chat belongs to.
  TextColumn get documentId => text()();

  TextColumn get title => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}