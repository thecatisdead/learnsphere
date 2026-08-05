import 'package:drift/drift.dart';
import 'package:learnsphere/database/app_database.dart';

class DocumentRepository {
  final AppDatabase db;

  DocumentRepository(this.db);

  Future<void> deleteDocument(String documentId) async {
    await (db.delete(db.documents)
      ..where((document) => document.id.equals(documentId))).go();
  }

  /// Finds a document using its SHA-256 hash.
  Future<Document?> getDocumentByHash(String contentHash) {
    return (db.select(db.documents)
          ..where((document) => document.contentHash.equals(contentHash))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Gets a document by its database ID.
  Future<Document?> getDocumentById(String id) {
    return (db.select(db.documents)
          ..where((document) => document.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Creates a new document.
  Future<void> createDocument({
    required String id,
    required String fileName,
    required String filePath,
    required String contentHash,
  }) async {
    final now = DateTime.now();

    await db
        .into(db.documents)
        .insert(
          DocumentsCompanion.insert(
            id: id,
            fileName: fileName,
            filePath: filePath,
            contentHash: contentHash,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Updates the file path of an existing document.
  ///
  /// Useful when the user deletes the local PDF and uploads
  /// the same PDF again. The content hash remains the same,
  /// so we reuse the existing document.
  Future<void> updateFilePath({
    required String documentId,
    required String filePath,
  }) async {
    await (db.update(db.documents)
      ..where((document) => document.id.equals(documentId))).write(
      DocumentsCompanion(
        filePath: Value(filePath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Gets all saved documents.
  Future<List<Document>> getDocuments() {
    return (db.select(db.documents)
      ..orderBy([(document) => OrderingTerm.desc(document.updatedAt)])).get();
  }

  Future<Document> getOrCreateDocument({
    required String id,
    required String fileName,
    required String filePath,
    required String contentHash,
  }) async {
    final existingDocument = await getDocumentByHash(contentHash);

    if (existingDocument != null) {
      await updateFilePath(documentId: existingDocument.id, filePath: filePath);

      final updatedDocument = await getDocumentById(existingDocument.id);

      return updatedDocument!;
    }

    await createDocument(
      id: id,
      fileName: fileName,
      filePath: filePath,
      contentHash: contentHash,
    );

    final document = await getDocumentById(id);

    return document!;
  }
}
