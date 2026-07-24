import 'package:flutter/material.dart';
import 'subject_card.dart';
import 'package:learnsphere/models/study_session.dart';

class RecentMaterialSection extends StatelessWidget {
final List<StudySession> recentMaterials;
final void Function(StudySession)? onMaterialTap;

  RecentMaterialSection({
    super.key,
    required this.recentMaterials,
    this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🔥 Recent Material"),
        SizedBox(height: 10),
        ...recentMaterials.map(
          (material) => SubjectCard(
            title: material.fileName,
            onTap: () {
              onMaterialTap?.call(material);
            },
          ),
        ),
      ],
    );
  }
}
