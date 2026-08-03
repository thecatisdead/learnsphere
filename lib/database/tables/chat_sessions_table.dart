import 'package:drift/drift.dart';

class ChatSessions extends Table {
  TextColumn get id => text()();

  TextColumn get fileName => text()();

  TextColumn get filePath => text()();

  TextColumn get title => text()();

  @override
  Set<Column> get primaryKey => {id};
}