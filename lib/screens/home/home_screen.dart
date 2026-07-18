import 'package:flutter/material.dart';
import 'package:learnsphere/screens/home/widgets/todays_goal.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/recent_material.dart';
import 'widgets/upload_card.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedFileName;

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
                setState(() {
                  recentMaterials.add(result.files.single.name);
                });
              } else {
                print('No file selected');
                // User canceled the picker
              }
            },
          ),
          RecentMaterialSection(recentMaterials: recentMaterials,
            onMaterialTap: (material) {
              print('Tapped on material: $material');
            },
          ),
          AIRecommendationCard(),
          TodaysGoalCard(),
        ],
      ),
    );
  }
}
