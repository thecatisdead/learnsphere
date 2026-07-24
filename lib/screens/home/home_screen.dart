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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final recentMaterials = ref.watch(recentMaterialsProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GreetingHeader(),
          SizedBox(height: 20),

          ContinueLearningCard(progress: 0.5),
          UploadCard(
            onTap: () async {
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (result != null) {
                final session = StudySession(
                  fileName: result.files.single.name,
                  filePath: result.files.single.path!,
                );

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

                ref.read(studySessionProvider.notifier).setSession(session);
              } else {
                print("No file selected");
              }
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
