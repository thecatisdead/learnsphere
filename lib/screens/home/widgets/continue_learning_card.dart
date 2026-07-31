import 'package:flutter/material.dart';
import 'package:learnsphere/shared/widgets/app_card_widget.dart';
import '../../../models/study_session.dart';

class ContinueLearningCard extends StatelessWidget {
  final StudySession session;
  final bool summaryReady;
  final bool quizReady;
  final bool flashcardsReady;

  final VoidCallback? onTap;

  const ContinueLearningCard({
    super.key,
    required this.session,
    required this.summaryReady,
    required this.quizReady,
    required this.flashcardsReady,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed =
        [
          summaryReady,
          quizReady,
          flashcardsReady,
        ].where((ready) => ready).length;

    final progress = completed / 3;

    return AppCard(
      child: InkWell(
        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📚 Continue Learning",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Text(
              session.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8),

            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                StatusLabel(label: "Summary", ready: summaryReady),
                StatusLabel(label: "Quiz", ready: quizReady),
                StatusLabel(label: "Flashcards", ready: flashcardsReady),
              ],
            ),
            SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: const Color.fromARGB(181, 0, 110, 255),
              minHeight: 12.0,
              borderRadius: BorderRadius.circular(8),
            ),

            SizedBox(height: 8),
            Text("${(progress * 100).toInt()}% Complete"),
          ],
        ),
      ),
    );
  }
}

class StatusLabel extends StatelessWidget {
  final String label;
  final bool ready;

  const StatusLabel({super.key, required this.label, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ready ? Icons.check_circle : Icons.circle_outlined,
          size: 15,
          color: ready ? const Color(0xFF2E7D32) : const Color(0xFF77746E),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ready ? const Color(0xFF2E7D32) : const Color(0xFF77746E),
          ),
        ),
      ],
    );
  }
}
