import 'package:flutter/material.dart';
import 'subject_card.dart';
import 'package:learnsphere/models/study_session.dart';

class RecentMaterialSection extends StatelessWidget {
  final List<StudySession> recentMaterials;
  final void Function(StudySession)? onMaterialTap;
  final Future<void> Function(StudySession)? onDelete;

  const RecentMaterialSection({
    super.key,
    required this.recentMaterials,
    this.onMaterialTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔥 Recent Material"),
        const SizedBox(height: 10),

        ...recentMaterials.map(
          (material) => GestureDetector(
            onLongPress: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete PDF?"),
                    content: Text(
                      'Delete "${material.fileName}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await onDelete?.call(material);
              }
            },
            child: SubjectCard(
              title: material.fileName,
              onTap: () {
                onMaterialTap?.call(material);
              },
            ),
          ),
        ),
      ],
    );
  }
}