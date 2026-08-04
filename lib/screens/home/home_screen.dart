import 'package:flutter/material.dart';
import 'package:learnsphere/screens/home/widgets/todays_goal.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/recent_material.dart';
import 'widgets/upload_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learnsphere/screens/study_material/study_material_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/study_session_provider.dart';
import '../../models/study_session.dart';
import '../../providers/recent_materials_provider.dart';
import '../../providers/ai_material_provider.dart';
import '../../services/ai_service.dart';
import '../../providers/pdf_text_provider.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_provider.dart';
import '../../database/chat_repository.dart';
import 'package:learnsphere/providers/chat_session_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:learnsphere/database/database_provider.dart';
import 'package:learnsphere/database/document_repository.dart';
import 'package:learnsphere/services/file_hash_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(chatSessionsProvider.notifier).loadAllChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentMaterials = ref.watch(recentMaterialsProvider);
    final aiMaterials = ref.watch(aiMaterialProvider);

    final session = ref.watch(studySessionProvider);

    final aiMaterial = session == null ? null : aiMaterials[session.filePath];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 60),
          GreetingHeader(),
          SizedBox(height: 20),

          if (session != null)
            ContinueLearningCard(
              session: session,
              summaryReady: aiMaterial?.summaryReady ?? false,
              quizReady: aiMaterial?.quizReady ?? false,
              flashcardsReady: aiMaterial?.flashcardsReady ?? false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudyMaterialScreen(),
                  ),
                );
              },
            ),

          UploadCard(
            onTap: () async {
              final result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (result == null) {
                return;
              }

              final fileName = result.files.single.name;
              final filePath = result.files.single.path!;

              print("📄 PDF SELECTED: $fileName");

              // --------------------------------------------------
              // 1. Calculate PDF identity
              // --------------------------------------------------

              final contentHash = await FileHashService.sha256File(filePath);

              print("🔐 PDF HASH: $contentHash");

              // --------------------------------------------------
              // 2. Find existing document or create a new one
              // --------------------------------------------------

              final documentRepository = DocumentRepository(
                ref.read(databaseProvider),
              );

              final document = await documentRepository.getOrCreateDocument(
                id: const Uuid().v4(),
                fileName: fileName,
                filePath: filePath,
                contentHash: contentHash,
              );

              print("📚 DOCUMENT ID: ${document.id}");

              // --------------------------------------------------
              // 3. Create StudySession
              // --------------------------------------------------

              final session = StudySession(
                documentId: document.id,
                fileName: document.fileName,
                filePath: document.filePath,
              );

              // --------------------------------------------------
              // 4. Extract PDF text
              // --------------------------------------------------

              final text = await ref
                  .read(pdfTextProvider.notifier)
                  .loadText(session.filePath);

              print("📚 Indexing ${session.fileName}");

              // --------------------------------------------------
              // 5. Index PDF for AI
              // --------------------------------------------------

              await AiService.indexPdf(fileName: session.fileName, text: text);

              print("✅ PDF indexed");

              // --------------------------------------------------
              // 6. Add to recent materials
              // --------------------------------------------------

              final added = ref
                  .read(recentMaterialsProvider.notifier)
                  .addMaterial(session);

              if (!added) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "You can only upload 5 PDFs. Delete one to upload another.",
                    ),
                  ),
                );
                return;
              }

              ref.read(aiMaterialProvider.notifier).addMaterial(session);

              // --------------------------------------------------
              // 7. Set current study session
              // --------------------------------------------------

              ref.read(studySessionProvider.notifier).setSession(session);

              print("✅ STUDY SESSION SET");
            },
          ),
          RecentMaterialSection(
            recentMaterials: recentMaterials,
            onMaterialTap: (material) {
              ref.read(studySessionProvider.notifier).setSession(material);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudyMaterialScreen(),
                ),
              );
            },
          ),
          AIRecommendationCard(),
          TodaysGoalCard(),
        ],
      ),
    );
  }
}
