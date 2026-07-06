import 'package:flutter/material.dart';
import 'subject_card.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🔥 Trending"),

        SubjectCard(title: "Flutter"),

        SubjectCard(title: "Firebase"),

        SubjectCard(title: "AI"),
      ],
    );
  }
}
