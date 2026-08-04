import 'package:drift/drift.dart';

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get chatId => text()();

  TextColumn get messageText => text()();

  BoolColumn get isUser => boolean()();

  DateTimeColumn get createdAt => dateTime()();
}
