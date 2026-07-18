import 'package:flutter/material.dart';
import 'subject_card.dart';

class RecentMaterialSection extends StatelessWidget {
  final List<String> recentMaterials;
  final void Function(String)? onMaterialTap;

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
            title: material,
            onTap: () {
              onMaterialTap?.call(material);
            },
          ),
        ),
      ],
    );
  }
}
