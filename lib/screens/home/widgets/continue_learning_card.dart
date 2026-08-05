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
    final theme = Theme.of(context);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text("📚", style: TextStyle(fontSize: 20)),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      "Continue Learning",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // File name
              Text(
                session.fileName.replaceAll('.pdf', ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "PDF",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 14),

              // AI features
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  StatusLabel(label: "Summary", ready: summaryReady),
                  StatusLabel(label: "Quiz", ready: quizReady),
                  StatusLabel(label: "Flashcards", ready: flashcardsReady),
                ],
              ),
            ],
          ),
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
          ready ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 15,
          color: ready ? const Color(0xFF2E7D32) : const Color(0xFF77746E),
        ),
        const SizedBox(width: 5),
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
