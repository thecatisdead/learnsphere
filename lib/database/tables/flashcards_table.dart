import 'package:drift/drift.dart';

class Flashcards extends Table {
  TextColumn get documentId => text()();

  TextColumn get flashcardJson => text()();

  @override
  Set<Column> get primaryKey => {documentId};
}
