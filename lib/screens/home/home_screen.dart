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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // List<StudySession> recentMaterials = [];
  List<String> recentMaterials = [];

  @override
  Widget build(BuildContext context) {
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
                print("1. PDF selected");

                ref
                    .read(studySessionProvider.notifier)
                    .setSession(
                      StudySession(
                        fileName: result.files.single.name,
                        filePath: result.files.single.path!,
                      ),
                    );

                print("2. Session saved");

                final session = ref.read(studySessionProvider);

                print("3. Session is: $session");
                print("4. File name: ${session?.fileName}");
                print("5. File path: ${session?.filePath}");

                setState(() {
                  recentMaterials.add(result.files.single.name);
                });
              } else {
                print('No file selected');

                // User canceled the picker
              }
            },
          ),
          RecentMaterialSection(
            recentMaterials: recentMaterials,
            onMaterialTap: (material) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyMaterialScreen(fileName: material),
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
