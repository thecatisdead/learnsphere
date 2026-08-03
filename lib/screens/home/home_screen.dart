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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (result != null) {
                final fileName = result.files.single.name;
                final filePath = result.files.single.path!;

                final chatId = await ref
                    .read(chatSessionsProvider.notifier)
                    .createChat(fileName: fileName, filePath: filePath);

                final session = StudySession(
                  chatId: chatId,
                  fileName: fileName,
                  filePath: filePath,
                );

                print("🆕 CHAT CREATED: $chatId");

                final text = await ref
                    .read(pdfTextProvider.notifier)
                    .loadText(session.filePath);

                print("📚 Indexing ${session.fileName}");

                await AiService.indexPdf(
                  fileName: session.fileName,
                  text: text,
                );

                print("✅ PDF indexed");

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

                ref.read(studySessionProvider.notifier).setSession(session);
              } else {}
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
