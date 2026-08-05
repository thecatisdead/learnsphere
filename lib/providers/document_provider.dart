import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_provider.dart';

import '../../database/document_repository.dart';

import 'package:learnsphere/database/app_database.dart';

final documentProvider = FutureProvider.family<Document?, String>((
  ref,
  documentId,
) {
  final repository = DocumentRepository(ref.read(databaseProvider));
  return repository.getDocumentById(documentId);
});
